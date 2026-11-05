#!/usr/bin/env python3
"""Helix-friendly competitive programming test runner.

Testcase names match CompetiTest.nvim's default multi-file storage.
"""
import argparse
import difflib
import json
import re
import subprocess
import sys
import tempfile
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

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


def create_problem(data):
    name = data.get("name")
    if not isinstance(name, str) or not name.strip():
        raise ValueError("Competitive Companion payload has no problem name")
    safe_name = re.sub(r"[^A-Za-z0-9._ -]", "_", name).strip(" .")[:100]
    if not safe_name or safe_name in {".", ".."}:
        raise ValueError("invalid problem name")
    source = Path.cwd() / (safe_name + ".cpp")
    template = Path.home() / "Documents/codeforces/template.cpp"
    content = template.read_text(encoding="utf-8") if template.is_file() else ""
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
    with source.open("x", encoding="utf-8") as file:
        file.write(content)
    print(f"Created problem: {source}")
    return source


def receive(source, port, timeout, new_problem=False):
    # Competitive Companion sends POST JSON with a tests array to localhost.
    class Handler(BaseHTTPRequestHandler):
        def do_POST(self):
            try:
                size = int(self.headers.get("Content-Length", "0"))
                if size <= 0 or size > MAX_BODY:
                    self.send_error(413, "invalid or oversized payload")
                    return
                data = json.loads(self.rfile.read(size))
                tests = data.get("tests")
                if not isinstance(tests, list) or not tests:
                    self.send_error(400, "missing tests")
                    return
                for test in tests:
                    if not isinstance(test, dict) or not isinstance(test.get("input"), str) or not isinstance(test.get("output", ""), str):
                        self.send_error(400, "invalid test")
                        return
                target = create_problem(data) if new_problem else source
                for test in tests:
                    add(target, test["input"], test.get("output", ""))
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"OK")
                self.server.received = True
            except (ValueError, UnicodeDecodeError, OSError) as exc:
                self.send_error(400, str(exc))

        def log_message(self, format, *args):
            pass

    with HTTPServer(("127.0.0.1", port), Handler) as server:
        server.timeout = timeout
        server.received = False
        print(f"Listening on 127.0.0.1:{port} for Competitive Companion (one problem, {timeout}s).", flush=True)
        server.handle_request()
        if not server.received:
            print("No valid problem received.", file=sys.stderr)
            return 1
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    for name in ("add", "list", "delete", "run", "receive", "receive-problem"):
        cmd = sub.add_parser(name)
        if name != "receive-problem":
            cmd.add_argument("source", help="solution file (save it first in Helix)")
        if name == "add":
            cmd.add_argument("--input", default="", help="input text (or edit generated file in Helix)")
            cmd.add_argument("--output", default="", help="expected output text")
        if name == "delete":
            cmd.add_argument("number", type=int)
        if name == "run":
            cmd.add_argument("--timeout", type=float, default=5)
            cmd.add_argument("--exact", action="store_true", help="compare exact bytes instead of whitespace-normalized output")
            cmd.add_argument("--diff", action="store_true", help="print unified diff on failure")
        if name in ("receive", "receive-problem"):
            cmd.add_argument("--port", type=int, default=27121)
            cmd.add_argument("--timeout", type=int, default=60)
    args = parser.parse_args(argv)
    try:
        source = None if args.action == "receive-problem" else source_path(args.source)
        if args.action == "add":
            add(source, args.input, args.output)
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
            return execute(source, args.timeout, args.exact, args.diff)
        elif args.action in ("receive", "receive-problem"):
            if args.timeout <= 0 or not 1 <= args.port <= 65535:
                raise ValueError("invalid port or timeout")
            return receive(source, args.port, args.timeout, args.action == "receive-problem")
        return 0
    except (ValueError, OSError) as exc:
        parser.error(str(exc))


if __name__ == "__main__":
    sys.exit(main())
