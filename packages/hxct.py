#!/usr/bin/env python3
"""Helix-friendly competitive programming test runner.

Testcase names match CompetiTest.nvim's default multi-file storage.
"""
import argparse
import difflib
import json
import re
import select
import socket
import subprocess
import sys
import tempfile
import time
from contextlib import ExitStack, nullcontext, redirect_stdout
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.parse import urlsplit

MAX_BODY = 2_000_000
MAX_OUTPUT = 1_000_000
SUPPORTED = {".c", ".cpp", ".cc", ".cxx", ".rs", ".py", ".java"}


def source_path(value):
    path = Path(value).expanduser().resolve()
    if not path.is_file() or path.suffix not in SUPPORTED:
        raise ValueError(f"expected an existing C, C++, Rust, Python, or Java source file: {path}")
    return path


def cases(source):
    pattern = re.compile(re.escape(source.stem) + r"_input([0-9]+)\.txt$")
    found = []
    for path in source.parent.iterdir():
        match = pattern.fullmatch(path.name)
        if match:
            number = int(match.group(1))
            found.append((number, path, source.with_name(f"{source.stem}_output{number}.txt")))
    return sorted(found)


def add(source, input_text, output_text):
    used = {number for number, _, _ in cases(source)}
    number = 0
    while (number in used or
           source.with_name(f"{source.stem}_output{number}.txt").exists()):
        number += 1
    input_path = source.with_name(f"{source.stem}_input{number}.txt")
    output_path = source.with_name(f"{source.stem}_output{number}.txt")
    input_path.write_text(input_text, encoding="utf-8")
    output_path.write_text(output_text, encoding="utf-8")
    print(f"Added case {number}: {input_path.name}, {output_path.name}")
    return number


def draw_add_case(screen, source):
    import curses

    fields = [[""], [""]]
    positions = [[0, 0], [0, 0]]
    active = 0
    screen.keypad(True)
    curses.raw()  # Disable XON/XOFF so Ctrl-S reaches the editor.
    try:
        curses.curs_set(1)
    except curses.error:
        pass
    while True:
        screen.erase()
        height, width = screen.getmaxyx()
        if height < 12 or width < 50:
            screen.addnstr(0, 0, "Resize to at least 50 × 12. Esc cancels.", max(0, width - 1))
        else:
            screen.addnstr(0, 1, f"Add testcase · {source.name}", width - 2, curses.A_BOLD)
            screen.addnstr(height - 2, 1, "Tab: switch  Enter: newline  Ctrl-S: save  Esc: cancel", width - 2)
            widths = [width // 2, width - width // 2]
            for index, label in enumerate(("Input", "Expected Output")):
                x = sum(widths[:index])
                win = screen.derwin(height - 3, widths[index], 1, x)
                win.box()
                win.addnstr(0, 2, f" {label} ", widths[index] - 4,
                            curses.A_BOLD if active == index else 0)
                lines = fields[index]
                row, col = positions[index]
                visible = height - 5
                offset = max(0, row - visible + 1)
                left = max(0, col - (widths[index] - 4))
                for visible_row, line in enumerate(lines[offset:offset + visible], start=1):
                    win.addnstr(visible_row, 1, line[left:].expandtabs(4), widths[index] - 2)
            row, col = positions[active]
            screen.move(2 + row - max(0, row - (height - 5) + 1),
                        sum(widths[:active]) + 1 + col - max(0, col - (widths[active] - 4)))
        screen.refresh()
        key = screen.get_wch()
        if key == "\x1b":
            return False
        if key == "\x13":  # Ctrl-S
            add(source, "\n".join(fields[0]), "\n".join(fields[1]))
            return True
        if key == "\t":
            active = 1 - active
            continue
        lines = fields[active]
        row, col = positions[active]
        if key in ("\n", "\r", curses.KEY_ENTER):
            line = lines[row]
            lines[row:row + 1] = [line[:col], line[col:]]
            row, col = row + 1, 0
        elif key in ("\b", "\x7f", curses.KEY_BACKSPACE):
            if col:
                lines[row] = lines[row][:col - 1] + lines[row][col:]
                col -= 1
            elif row:
                col = len(lines[row - 1])
                lines[row - 1:row + 1] = [lines[row - 1] + lines[row]]
                row -= 1
        elif key == curses.KEY_DC:
            if col < len(lines[row]):
                lines[row] = lines[row][:col] + lines[row][col + 1:]
            elif row + 1 < len(lines):
                lines[row:row + 2] = [lines[row] + lines[row + 1]]
        elif key == curses.KEY_UP:
            row = max(0, row - 1)
            col = min(col, len(lines[row]))
        elif key == curses.KEY_DOWN:
            row = min(len(lines) - 1, row + 1)
            col = min(col, len(lines[row]))
        elif key == curses.KEY_LEFT:
            col = max(0, col - 1)
        elif key == curses.KEY_RIGHT:
            col = min(len(lines[row]), col + 1)
        elif key == curses.KEY_HOME:
            col = 0
        elif key == curses.KEY_END:
            col = len(lines[row])
        elif isinstance(key, str) and key.isprintable():
            lines[row] = lines[row][:col] + key + lines[row][col:]
            col += 1
        positions[active] = [row, col]


def normalize(text, exact):
    return text if exact else " ".join(text.split())


def command_for(source, binary):
    suffix = source.suffix
    if suffix == ".c":
        return ["gcc", "-O2", "-std=c11", str(source), "-o", str(binary)], [str(binary)]
    if suffix in {".cpp", ".cc", ".cxx"}:
        return ["g++", "-O2", "-std=c++17", str(source), "-o", str(binary)], [str(binary)]
    if suffix == ".rs":
        return ["rustc", "-O", str(source), "-o", str(binary)], [str(binary)]
    if suffix == ".java":
        return ["javac", "-d", str(binary.parent), str(source)], ["java", "-cp", str(binary.parent), source.stem]
    return None, [sys.executable, str(source)]


def execute(source, timeout, exact, show_diff):
    found = cases(source)
    if not found:
        print("No cases. Use hxct add SOURCE or hxct receive SOURCE.", file=sys.stderr)
        return 2
    # Use an isolated build directory; do not leave compiled executables in a contest folder.
    with tempfile.TemporaryDirectory(prefix="hxct-") as directory:
        binary = Path(directory) / "solution"
        compile_cmd, run_cmd = command_for(source, binary)
        if compile_cmd:
            try:
                build = subprocess.run(compile_cmd, cwd=source.parent, capture_output=True,
                                       text=True, timeout=60, check=False)
            except (OSError, subprocess.TimeoutExpired) as exc:
                print(f"Compile failed: {exc}", file=sys.stderr)
                return 2
            if build.returncode:
                print(build.stdout + build.stderr, file=sys.stderr)
                return 2
        failed = 0
        for number, input_path, output_path in found:
            expected = output_path.read_text(encoding="utf-8") if output_path.exists() else None
            try:
                result = subprocess.run(run_cmd, cwd=source.parent,
                                        input=input_path.read_text(encoding="utf-8"),
                                        capture_output=True, text=True, errors="replace",
                                        timeout=timeout, check=False)
                actual = result.stdout[:MAX_OUTPUT]
                oversized = len(result.stdout) > MAX_OUTPUT
                ok = (result.returncode == 0 and not oversized and
                      (expected is None or normalize(actual, exact) == normalize(expected, exact)))
                status = "PASS" if ok else "FAIL"
                print(f"[{status}] case {number}" + (" (no expected output)" if expected is None else ""))
                if not ok:
                    failed += 1
                    if result.returncode:
                        print(f"  exit code: {result.returncode}")
                    if oversized:
                        print(f"  output exceeded {MAX_OUTPUT} characters")
                    if result.stderr:
                        print("  stderr: " + result.stderr[:2000])
                    if expected is not None:
                        print("  expected: " + repr(expected[:2000]))
                    print("  actual:   " + repr(actual[:2000]))
                    if show_diff and expected is not None:
                        print("".join(difflib.unified_diff(expected.splitlines(True), actual.splitlines(True),
                                                           fromfile="expected", tofile="actual"))[:5000])
            except subprocess.TimeoutExpired:
                failed += 1
                print(f"[TIMEOUT] case {number} (>{timeout}s)")
            except OSError as exc:
                print(f"Run failed: {exc}", file=sys.stderr)
                return 2
        print(f"{len(found) - failed}/{len(found)} passed")
        return 1 if failed else 0


def collect_ui_results(source, timeout, exact):
    found = cases(source)
    if not found:
        return "NO CASES", 0.0, "No testcases. Use hxct add or receive.", []
    with tempfile.TemporaryDirectory(prefix="hxct-") as directory:
        compile_cmd, run_cmd = command_for(source, Path(directory) / "solution")
        compile_time = 0.0
        if compile_cmd:
            start = time.perf_counter()
            try:
                build = subprocess.run(compile_cmd, cwd=source.parent, capture_output=True,
                                       text=True, errors="replace", timeout=60, check=False)
            except (OSError, subprocess.TimeoutExpired) as exc:
                return "FAILED", time.perf_counter() - start, str(exc), []
            compile_time = time.perf_counter() - start
            if build.returncode:
                return "FAILED", compile_time, (build.stdout + build.stderr)[:MAX_OUTPUT], []
        results = []
        for number, input_path, output_path in found:
            input_text = input_path.read_text(encoding="utf-8")
            expected = output_path.read_text(encoding="utf-8") if output_path.exists() else None
            start = time.perf_counter()
            try:
                run = subprocess.run(run_cmd, cwd=source.parent, input=input_text,
                                     capture_output=True, text=True, errors="replace",
                                     timeout=timeout, check=False)
                elapsed = time.perf_counter() - start
                actual = run.stdout[:MAX_OUTPUT]
                oversized = len(run.stdout) > MAX_OUTPUT
                matches = expected is None or normalize(actual, exact) == normalize(expected, exact)
                if oversized:
                    status = "LIMIT"
                elif run.returncode:
                    status = "RUNTIME"
                elif not matches:
                    status = "WRONG"
                else:
                    status = "CORRECT"
                error = run.stderr[:MAX_OUTPUT]
                if run.returncode:
                    error = f"Exit code: {run.returncode}\n" + error
                if oversized:
                    error = f"Output exceeded {MAX_OUTPUT} characters\n" + error
                if not matches and expected is not None:
                    error += "\n" + "".join(difflib.unified_diff(
                        expected.splitlines(True), actual.splitlines(True),
                        fromfile="expected", tofile="actual"))[:5000]
            except subprocess.TimeoutExpired as exc:
                elapsed = time.perf_counter() - start
                status = "TIMEOUT"
                actual = (exc.stdout or b"").decode(errors="replace") if isinstance(exc.stdout, bytes) else (exc.stdout or "")
                error = f"Timed out after {timeout:g}s"
            except OSError as exc:
                elapsed = time.perf_counter() - start
                status, actual, error = "ERROR", "", str(exc)
            results.append(dict(number=number, status=status, elapsed=elapsed,
                                input=input_text, expected=expected, output=actual, errors=error))
        return "DONE", compile_time, "", results


def draw_results(screen, source, compile_status, compile_time, compile_error, results):
    import curses

    try:
        curses.curs_set(0)
    except curses.error:
        pass
    if curses.has_colors():
        curses.use_default_colors()
        for index, color in enumerate((curses.COLOR_BLUE, curses.COLOR_GREEN,
                                       curses.COLOR_RED, curses.COLOR_YELLOW), start=1):
            curses.init_pair(index, color, -1)
    border = curses.color_pair(1) if curses.has_colors() else 0
    good = curses.color_pair(2) if curses.has_colors() else curses.A_BOLD
    bad = curses.color_pair(3) if curses.has_colors() else curses.A_BOLD
    warning = curses.color_pair(4) if curses.has_colors() else curses.A_BOLD
    selected, focus = 0, 0
    scrolls = [0, 0, 0, 0]
    titles = ("Output", "Expected Output", "Input", "Errors")

    def put(win, row, col, value, attr=0):
        height, width = win.getmaxyx()
        if row >= height or col >= width:
            return
        value = "".join("?" if ord(ch) < 32 else ch for ch in value.expandtabs(4))
        try:
            win.addnstr(row, col, value, max(0, width - col - 1), attr)
        except curses.error:
            pass

    def panel(y, x, height, width, title, body, offset=0, active=False):
        win = screen.derwin(height, width, y, x)
        win.attron(warning if active else border)
        win.box()
        win.attroff(warning if active else border)
        put(win, 0, max(2, (width - len(title) - 2) // 2), f" {title} ", warning if active else border)
        lines = body.splitlines() if body else ["(empty)"]
        for row, line in enumerate(lines[offset:offset + max(0, height - 2)], start=1):
            put(win, row, 2, line)

    screen.keypad(True)
    while True:
        screen.erase()
        height, width = screen.getmaxyx()
        if height < 15 or width < 80:
            put(screen, 0, 0, "Resize terminal to at least 80 columns × 15 rows; q closes.")
        else:
            main_height = height - 2
            left_width = min(max(width // 3, 25), 40)
            right_width = width - left_width
            first_width = right_width // 2
            second_width = right_width - first_width
            top_height = main_height // 2
            left = screen.derwin(main_height, left_width, 0, 0)
            left.attron(border)
            left.box()
            left.attroff(border)
            put(left, 0, max(2, (left_width - 11) // 2), " Testcases ", border)
            put(left, 1, 2, f"Compile {compile_status} {compile_time:.3f}s",
                good if compile_status == "DONE" else bad)
            visible = max(0, main_height - 4)
            start = max(0, min(selected - visible + 1, len(results) - visible)) if results else 0
            for row, item in enumerate(results[start:start + visible], start=2):
                status = item["status"]
                attr = good if status == "CORRECT" else (warning if status == "TIMEOUT" else bad)
                if start + row - 2 == selected:
                    attr |= curses.A_REVERSE
                put(left, row, 2, f"TC {item['number']:<3} {status:<7} {item['elapsed']:.3f}s", attr)
            current = results[selected] if results else None
            bodies = (
                current["output"] if current else "",
                (current["expected"] if current and current["expected"] is not None else "(not provided)"),
                current["input"] if current else "",
                current["errors"] if current else compile_error,
            )
            positions = ((0, left_width, top_height, first_width),
                         (0, left_width + first_width, top_height, second_width),
                         (top_height, left_width, main_height - top_height, first_width),
                         (top_height, left_width + first_width, main_height - top_height, second_width))
            for index, (y, x, h, w) in enumerate(positions):
                panel(y, x, h, w, titles[index], bodies[index], scrolls[index], focus == index)
            passed = sum(item["status"] == "CORRECT" for item in results)
            put(screen, height - 2, 1, f"{source.name} · {passed}/{len(results)} correct")
            put(screen, height - 1, 1, "j/k: testcase   Tab: pane   PgUp/PgDn: scroll   q/Esc: close")
        screen.refresh()
        key = screen.getch()
        if key in (ord("q"), 27):
            return
        if key in (ord("j"), curses.KEY_DOWN) and results:
            selected = min(selected + 1, len(results) - 1)
            scrolls = [0, 0, 0, 0]
        elif key in (ord("k"), curses.KEY_UP) and results:
            selected = max(selected - 1, 0)
            scrolls = [0, 0, 0, 0]
        elif key == 9:
            focus = (focus + 1) % 4
        elif key == curses.KEY_NPAGE:
            scrolls[focus] += max(1, height // 2 - 3)
        elif key == curses.KEY_PPAGE:
            scrolls[focus] = max(0, scrolls[focus] - max(1, height // 2 - 3))


def launch_result_window(source, timeout, exact):
    import os
    if not (os.environ.get("WAYLAND_DISPLAY") or os.environ.get("DISPLAY")):
        raise ValueError("no graphical display; use hxct run SOURCE --tui in a terminal")
    command = ["alacritty", "--class", "hxct-testcases", "--title", "hxct testcases",
               "--option", "window.dimensions.columns=110",
               "--option", "window.dimensions.lines=30",
               "--working-directory", str(source.parent), "--command", sys.executable, __file__,
               "run", str(source), "--tui", "--timeout", str(timeout)]
    if exact:
        command.append("--exact")
    subprocess.Popen(command, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                     stderr=subprocess.DEVNULL, start_new_session=True)
    return 0


def launch_add_window(source):
    import os
    if not (os.environ.get("WAYLAND_DISPLAY") or os.environ.get("DISPLAY")):
        raise ValueError("no graphical display; use hxct add SOURCE --tui in a terminal")
    command = ["alacritty", "--class", "hxct-testcases", "--title", "hxct add testcase",
               "--option", "window.dimensions.columns=110",
               "--option", "window.dimensions.lines=30",
               "--working-directory", str(source.parent), "--command", sys.executable,
               __file__, "add", str(source), "--tui"]
    subprocess.Popen(command, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                     stderr=subprocess.DEVNULL, start_new_session=True)
    return 0


def filename_path(filename, root=None):
    filename = filename.strip()
    if (not filename or len(filename) > 240 or filename.startswith("/") or
            "\\" in filename or any(ord(ch) < 32 for ch in filename)):
        raise ValueError("enter a relative .cpp path of at most 240 characters")
    parts = filename.split("/")
    if any(part in {"", ".", ".."} or len(part) > 100 for part in parts):
        raise ValueError("path components must be 1–100 characters without . or ..")
    if not parts[-1].endswith(".cpp"):
        if Path(parts[-1]).suffix:
            raise ValueError("problem source must be a .cpp file")
        filename += ".cpp"
    root = Path(root).resolve() if root is not None else Path.cwd().resolve()
    source = (root / filename).resolve()
    if not source.is_relative_to(root):
        raise ValueError("problem source must stay inside the current directory")
    if source.exists():
        raise ValueError(f"source already exists: {source}; choose another filename")
    return source


def prompt_filename(default):
    try:
        result = subprocess.run(
            ["fuzzel", "--dmenu", "--prompt-only=Problem path: ",
             f"--search={default}"],
            capture_output=True, text=True, check=False,
        )
    except OSError as exc:
        raise ValueError(f"filename prompt unavailable (Fuzzel): {exc}") from exc
    if result.returncode != 0:
        if result.stderr.strip():
            raise ValueError(f"filename prompt failed: {result.stderr.strip()}")
        return None  # Esc cancels without writing a file.
    return result.stdout.strip()


def problem_filename(data):
    name = data.get("name")
    if not isinstance(name, str) or not name.strip():
        raise ValueError("Competitive Companion payload has no problem name")
    url = data.get("url", "")
    if isinstance(url, str):
        parsed = urlsplit(url)
        host = (parsed.hostname or "").removeprefix("www.").lower()
        path = parsed.path
        if host == "codeforces.com":
            match = (re.search(r"/(?:contest|gym)/(\d+)/problem/([A-Za-z0-9]+)(?:/|$)", path) or
                     re.search(r"/problemset/problem/(\d+)/([A-Za-z0-9]+)(?:/|$)", path))
            if match:
                return f"codeforces/{match[1]}/{match[2].upper()}.cpp"
        if host == "atcoder.jp":
            match = re.search(r"/contests/([A-Za-z0-9_-]+)/tasks/([A-Za-z0-9_-]+)(?:/|$)", path)
            if match:
                contest, task = match.groups()
                number = task.removeprefix(contest + "_")
                return f"atcoder/{contest}/{number.upper()}.cpp"
        if host and "." in host:
            match = re.search(
                r"/(?:contest|contests|round|rounds)/([A-Za-z0-9_-]+)"
                r"/(?:problem|problems)/([A-Za-z0-9_-]+)(?:/|$)", path)
            if match:
                judge = host.split(".")[0]
                return f"{judge}/{match[1]}/{match[2]}.cpp"
    safe_name = re.sub(r"[^A-Za-z0-9._ -]", "_", name).strip(" .")[:96]
    if not safe_name or safe_name in {".", ".."}:
        raise ValueError("invalid problem name")
    return safe_name + ".cpp"


def create_problem(data, filename=None, root=None):
    name = data.get("name")
    source = filename_path(filename if filename is not None else problem_filename(data), root)
    templates = (Path.home() / "Documents/codeforces/misc/template.cpp",
                 Path.home() / "Documents/codeforces/template.cpp")
    template = next((path for path in templates if path.is_file()), None)
    if template is None:
        raise ValueError(f"C++ template not found: {templates[0]}")
    content = template.read_text(encoding="utf-8")
    values = {
        "PROBLEM": name,
        "CONTEST": data.get("group", ""),
        "JUDGE": data.get("site", ""),
        "URL": data.get("url", ""),
        "MEMLIM": data.get("memoryLimit", ""),
        "TIMELIM": data.get("timeLimit", ""),
        "DATE": datetime.now().strftime("%c"),
    }
    for key, value in values.items():
        # Metadata is browser-supplied; do not allow comment terminators/newlines
        # in the generated C++ template header.
        clean = re.sub(r"[\r\n*/]", "_", str(value))
        content = content.replace("$(" + key + ")", clean)
    source.parent.mkdir(parents=True, exist_ok=True)
    with source.open("x", encoding="utf-8") as file:
        file.write(content)
    print(f"Created problem: {source}")
    return source


def new_problem(filename=None, prompt=False, path_only=False, misc=False):
    chosen = prompt_filename("problem.cpp") if prompt else filename
    if chosen is None:
        return 0  # Esc cancels without creating a file.
    root = Path.home() / "Documents/codeforces/misc" if misc else None
    with (redirect_stdout(sys.stderr) if path_only else nullcontext()):
        source = create_problem({"name": Path(chosen).stem}, chosen, root)
    if path_only:
        print(source)
    return 0


def receive(source, port, timeout, new_problem=False, filename=None, prompt=False, path_only=False):
    # Competitive Companion sends POST JSON with a tests array to localhost.
    class Handler(BaseHTTPRequestHandler):
        def do_POST(self):
            try:
                size = int(self.headers.get("Content-Length", "0"))
                if size <= 0 or size > MAX_BODY:
                    print("Rejected problem: invalid or oversized payload", file=sys.stderr, flush=True)
                    self.send_error(413, "invalid or oversized payload")
                    return
                data = json.loads(self.rfile.read(size))
                if not isinstance(data, dict):
                    raise ValueError("expected a problem object")
                tests = data.get("tests")
                if not isinstance(tests, list) or not tests:
                    raise ValueError("missing tests")
                for test in tests:
                    if not isinstance(test, dict) or not isinstance(test.get("input"), str) or not isinstance(test.get("output", ""), str):
                        raise ValueError("invalid test")
                if prompt:
                    problem_filename(data)  # Validate before acknowledging receipt.
                    self.server.problem = data
                else:
                    target = create_problem(data, filename) if new_problem else source
                    for test in tests:
                        add(target, test["input"], test.get("output", ""))
                self.send_response(200)
                self.send_header("Content-Length", "2")
                self.end_headers()
                self.wfile.write(b"OK")
                self.server.received = True
            except (ValueError, UnicodeDecodeError, OSError) as exc:
                print(f"Rejected problem: {exc}", file=sys.stderr, flush=True)
                self.send_error(400, str(exc))

        def log_message(self, format, *args):
            pass

    class IPv6HTTPServer(HTTPServer):
        address_family = socket.AF_INET6

    received_problem = None
    with ExitStack() as stack:
        servers = [stack.enter_context(HTTPServer(("127.0.0.1", port), Handler))]
        try:
            servers.append(stack.enter_context(IPv6HTTPServer(("::1", port), Handler)))
        except OSError as exc:
            print(f"IPv6 localhost unavailable: {exc}", file=sys.stderr)
        for server in servers:
            server.received = False
        addresses = ", ".join(f"{server.server_address[0]}:{port}" for server in servers)
        print(f"Listening on {addresses} for Competitive Companion (one problem, {timeout}s).",
              file=sys.stderr if path_only else sys.stdout, flush=True)
        deadline = time.monotonic() + timeout
        while not any(server.received for server in servers):
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                print("No valid problem received before timeout.", file=sys.stderr)
                return 1
            readable, _, _ = select.select([server.socket for server in servers], [], [], remaining)
            for server in servers:
                if server.socket in readable:
                    server._handle_request_noblock()
                    break
        if prompt:
            received_problem = next(server.problem for server in servers if server.received)
    # The HTTP response and listener are closed before the user sees the dialog.
    if received_problem is not None:
        chosen = prompt_filename(problem_filename(received_problem))
        if chosen is None:
            print("Cancelled problem import.", file=sys.stderr if path_only else sys.stdout)
            return 0
        with (redirect_stdout(sys.stderr) if path_only else nullcontext()):
            target = create_problem(received_problem, chosen)
            for test in received_problem["tests"]:
                add(target, test["input"], test.get("output", ""))
        if path_only:
            print(target)  # A single quoted Helix :open expansion consumes this path.
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    for name in ("add", "list", "delete", "run", "receive", "receive-problem", "new"):
        cmd = sub.add_parser(name)
        if name not in ("receive-problem", "new"):
            cmd.add_argument("source", help="solution file (save it first in Helix)")
        if name == "add":
            cmd.add_argument("--input", default="", help="input text (or edit generated file in Helix)")
            cmd.add_argument("--output", default="", help="expected output text")
            ui_modes = cmd.add_mutually_exclusive_group()
            ui_modes.add_argument("--window", action="store_true", help="open a floating testcase editor")
            ui_modes.add_argument("--tui", action="store_true", help="edit in the current terminal")
        if name == "delete":
            cmd.add_argument("number", type=int)
        if name == "run":
            cmd.add_argument("--timeout", type=float, default=5)
            cmd.add_argument("--exact", action="store_true", help="compare exact bytes instead of whitespace-normalized output")
            cmd.add_argument("--diff", action="store_true", help="print unified diff on failure")
            ui_modes = cmd.add_mutually_exclusive_group()
            ui_modes.add_argument("--window", action="store_true", help="show a floating Alacritty test window")
            ui_modes.add_argument("--tui", action="store_true", help="show full-screen panes in this terminal")
        if name in ("receive", "receive-problem"):
            cmd.add_argument("--port", type=int, default=27121)
            cmd.add_argument("--timeout", type=int, default=60)
        if name == "receive-problem":
            filename_options = cmd.add_mutually_exclusive_group()
            filename_options.add_argument("--prompt", action="store_true", help="ask for a relative .cpp path in Fuzzel")
            filename_options.add_argument("--name", help="output .cpp path relative to the current directory")
            cmd.add_argument("--path-only", action="store_true", help="print only the created path for Helix :open")
        if name == "new":
            filename_options = cmd.add_mutually_exclusive_group(required=True)
            filename_options.add_argument("--prompt", action="store_true", help="ask for a relative .cpp path in Fuzzel")
            filename_options.add_argument("--name", help="new .cpp path relative to the target directory")
            cmd.add_argument("--misc", action="store_true", help="create under ~/Documents/codeforces/misc instead of the current directory")
            cmd.add_argument("--path-only", action="store_true", help="print only the created path for Helix :open")
    args = parser.parse_args(argv)
    try:
        source = None if args.action in ("receive-problem", "new") else source_path(args.source)
        if args.action == "add":
            if args.window:
                return launch_add_window(source)
            if args.tui:
                import curses
                if not sys.stdin.isatty() or not sys.stdout.isatty():
                    raise ValueError("--tui requires a terminal; use --window in Helix")
                curses.wrapper(draw_add_case, source)
                return 0
            add(source, args.input, args.output)
        elif args.action == "new":
            if args.path_only and not args.prompt:
                raise ValueError("--path-only requires --prompt")
            if args.name is not None:
                root = Path.home() / "Documents/codeforces/misc" if args.misc else None
                filename_path(args.name, root)  # Reject collisions before any writes.
            return new_problem(args.name, args.prompt, args.path_only, args.misc)
        elif args.action == "list":
            for number, input_path, output_path in cases(source):
                print(f"{number}: {input_path} | {output_path}")
        elif args.action == "delete":
            selected = [(i, p, q) for i, p, q in cases(source) if i == args.number]
            if not selected:
                raise ValueError(f"case {args.number} not found")
            _, input_path, output_path = selected[0]
            input_path.unlink()
            output_path.unlink(missing_ok=True)
            print(f"Deleted case {args.number}")
        elif args.action == "run":
            if args.timeout <= 0:
                raise ValueError("timeout must be positive")
            if args.window:
                return launch_result_window(source, args.timeout, args.exact)
            if args.tui:
                import curses
                if not sys.stdin.isatty() or not sys.stdout.isatty():
                    raise ValueError("--tui requires a terminal; use --window in Helix")
                details = collect_ui_results(source, args.timeout, args.exact)
                curses.wrapper(draw_results, source, *details)
                return 0
            return execute(source, args.timeout, args.exact, args.diff)
        elif args.action in ("receive", "receive-problem"):
            if args.timeout <= 0 or not 1 <= args.port <= 65535:
                raise ValueError("invalid port or timeout")
            filename = args.name if args.action == "receive-problem" else None
            if filename is not None:
                filename_path(filename)  # Explicit names fail before listening on collisions.
            if args.action == "receive-problem" and args.path_only and not args.prompt:
                raise ValueError("--path-only requires --prompt")
            return receive(source, args.port, args.timeout,
                           args.action == "receive-problem", filename,
                           args.action == "receive-problem" and args.prompt,
                           args.action == "receive-problem" and args.path_only)
        return 0
    except (ValueError, OSError) as exc:
        parser.error(str(exc))


if __name__ == "__main__":
    sys.exit(main())
