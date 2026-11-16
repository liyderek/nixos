# Helix testcase helper

Helix cannot load Neovim plugins. This Nix-managed `hxct` CLI brings the core
CompetiTest-style workflow into Helix without a separate repository.

After rebuilding, in a saved C/C++/Rust/Python/Java solution buffer:

| Keys | Action |
| --- | --- |
| Space t a | Save and create empty input/output testcase files |
| Space t l | List testcase file paths and numbers |
| Space r r | Save, compile, and open a floating Alacritty testcase dashboard |
| Space r p | Receive a C++ problem, prompt for its relative path, then open it in Helix |
| Space r n | Rename symbol (Helix's former Space r action) |
| Space t c | Save and import samples into the current solution |

Testcase names match CompetiTest.nvim's default multi-file naming:
`task_input0.txt`, `task_output0.txt`, etc. Open and edit these in Helix with
`:open task_input0.txt` and `:open task_output0.txt` or the file picker.
Delete a numbered case with `hxct delete SOURCE NUMBER` in a terminal.
Deletion cannot be undone.

For problem import, install the Competitive Companion browser extension.
Press Space r p to start the listener, then press the extension button on the
problem page within 60 seconds. Only after the problem arrives, Fuzzel prompts
for its `.cpp` path, prefilled from the judge URL. For example, a Codeforces
contest 2283 problem F defaults to `codeforces/2283/F.cpp` under Helix’s
current working directory. Codeforces contest/problemset/gym URLs, AtCoder
contest task URLs, and other `/contests/ROUND/problems/ID` URL shapes are
supported; unknown URLs fall back to the sanitized problem name in the current
directory. Edit the relative path if you like and press Enter; `.cpp` can be
omitted. Missing directories are created after confirmation. Escape cancels
without creating files or directories; existing sources are never overwritten.
On success, Helix opens the new source automatically.
If Helix and the browser run on the same host, no SSH forwarding is needed.
If Helix is on an SSH host but the browser is local, connect with local port
forwarding first:
`ssh -L 27121:127.0.0.1:27121 USER@HOST`. The extension posts to the
browser machine's localhost; this tunnel carries that request to the remote
Helix listener. Keep that SSH connection open, use port 27121 in the extension,
and click its button while the listener is active. Without the tunnel in
the SSH case, `hxct` times out. The graphical filename prompt requires a
Wayland session; for headless use `hxct receive-problem --name codeforces/2283/F.cpp`.
It accepts both IPv4 and IPv6 localhost; rejected payloads print a reason.
A successful import creates the chosen `.cpp` file under Helix's working
directory, using `~/Documents/codeforces/template.cpp` if present, and adds
the samples alongside it.
Don't press Space r p a second time while the first listener is active:
both attempts use port 27121.
Space t c instead appends samples to an existing source file. Both commands
listen at loopback port 27121 for 60 seconds; from a terminal use
`hxct receive-problem --port 27122 --timeout 120` for another port.

In a terminal: `hxct add SOURCE --input '2 3' --output '5'`,
`hxct run SOURCE --diff`, `hxct run SOURCE --exact` (byte comparison),
or `hxct run SOURCE --timeout 2`. Space r r opens a separate floating
Alacritty window with testcase statuses and output/expected/input/errors panes.
Use j/k (or arrows) to select cases, Tab to focus a pane, PgUp/PgDn to scroll,
and q/Esc to close. From a terminal, `hxct run SOURCE --tui` uses the current
terminal instead; `hxct run SOURCE --window` launches the same window. The
plain `hxct run` CLI still returns nonzero on failing tests. Default comparison
ignores whitespace differences; each case has a five-second limit.
Compilers (gcc/g++, rustc, javac/java) must be on PATH. Run only code and payloads you trust.

Not implemented: an in-editor Helix overlay, single-file msgpack conversion,
no-recompile mode, per-folder Lua config, custom compile commands, and
automatic creation of entire contests or contest-directory prompts.
