#!/usr/bin/env python3
"""Build one C++ file and bridge its LLDB-DAP stdio to a visible terminal."""

import hashlib
import os
import pty
import selectors
import subprocess
import sys
import tempfile
import termios
import time
import tty
from pathlib import Path


def source_key(source):
    return hashlib.sha256(str(Path(source).resolve()).encode()).hexdigest()[:24]


def cache_dir():
    path = Path(os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache"))) / "helix-debug"
    path.mkdir(parents=True, exist_ok=True)
    return path


def echo_input(data):
    # The debuggee's PTY echo is off, so only typed input gets the pink color.
    visible = bytearray()
    for char in data:
        if char in (10, 13):
            visible.extend(b"\r\n")
        elif char in (8, 127):
            visible.extend(b"\b \b")
        elif char == 9 or char >= 32 and char != 127:
            visible.append(char)
    if visible:
        os.write(1, b"\x1b[38;2;245;194;231m" + visible + b"\x1b[0m")


def bridge(ready):
    master, slave = pty.openpty()
    slave_mode = termios.tcgetattr(slave)
    slave_mode[3] &= ~termios.ECHO
    termios.tcsetattr(slave, termios.TCSANOW, slave_mode)
    old = termios.tcgetattr(0)
    tty.setraw(0)
    selector = selectors.DefaultSelector()
    selector.register(0, selectors.EVENT_READ)
    selector.register(master, selectors.EVENT_READ)
    Path(ready).write_text(os.ttyname(slave))
    try:
        while True:
            for key, _ in selector.select():
                data = os.read(key.fd, 4096)
                if not data:
                    return
                if key.fd == 0:
                    os.write(master, data)
                    echo_input(data)
                else:
                    os.write(1, data)
    finally:
        Path(ready).unlink(missing_ok=True)
        termios.tcsetattr(0, termios.TCSADRAIN, old)
        os.close(master)
        os.close(slave)


def build(source):
    cache = cache_dir()
    manifest = cache / ("io-" + source_key(source))
    manifest.unlink(missing_ok=True)  # Failed builds must never reuse an old terminal.
    if not (os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY")):
        raise RuntimeError("a graphical session is required for the LLDB I/O terminal")
    result = subprocess.run(
        [os.environ["HXDBG_BASH"], os.environ["HXDBG_HELPER"],
         os.environ["HXDBG_COMPILER"], source],
        text=True, capture_output=True, check=False,
    )
    if result.returncode:
        sys.stderr.write(result.stderr)
        raise SystemExit(result.returncode)
    program = result.stdout.strip()
    if not program or not Path(program).is_file():
        raise RuntimeError("C++ build did not produce a debugger executable")

    session = Path(tempfile.mkdtemp(prefix="io-", dir=cache))
    ready = session / "tty"
    log = session / "terminal.log"
    with log.open("w") as output:
        process = subprocess.Popen(
            [os.environ["HXDBG_ALACRITTY"], "--class", "hxdbg-io",
             "--title", "Helix Debug I/O",
             "--option", "window.dimensions.columns=110",
             "--option", "window.dimensions.lines=30",
             "--hold", "-e", os.environ["HXDBG_PYTHON"], __file__,
             "bridge", str(ready)],
            stdin=subprocess.DEVNULL, stdout=output, stderr=output,
            start_new_session=True,
        )
    for _ in range(100):
        if ready.is_file():
            terminal = ready.read_text().strip()
            if terminal.startswith("/dev/pts/") and Path(terminal).exists():
                manifest.write_text(f"{terminal}\n{ready}\n")
                print(program)
                return
        if process.poll() is not None:
            break
        time.sleep(0.1)
    if process.poll() is None:
        process.terminate()
    raise RuntimeError(f"I/O terminal did not start; see {log}")


def terminal_path(source):
    manifest = cache_dir() / ("io-" + source_key(source))
    if not manifest.is_file():
        raise RuntimeError("no I/O terminal for current build")
    terminal, ready = manifest.read_text().splitlines()
    if not Path(ready).is_file() or Path(ready).read_text().strip() != terminal or not Path(terminal).exists():
        raise RuntimeError("I/O terminal closed; start debugging again")
    print(terminal)


if __name__ == "__main__":
    try:
        if len(sys.argv) == 3 and sys.argv[1] == "bridge":
            bridge(sys.argv[2])
        elif len(sys.argv) == 3 and sys.argv[1] == "build":
            build(sys.argv[2])
        elif len(sys.argv) == 3 and sys.argv[1] == "tty":
            terminal_path(sys.argv[2])
        else:
            raise RuntimeError("usage: hxdbg-io {build|tty} SOURCE")
    except (OSError, RuntimeError) as error:
        print(f"hxdbg-io: {error}", file=sys.stderr)
        sys.exit(1)
