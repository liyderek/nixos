# Helix testcase helper

Helix cannot load Neovim plugins. This Nix-managed `hxct` CLI brings the core
CompetiTest-style workflow into Helix without a separate repository.

After rebuilding, in a saved C/C++/Rust/Python/Java solution buffer:

| Keys | Action |
| --- | --- |
| Space t a | Save and create empty input/output testcase files |
| Space t l | List testcase file paths and numbers |
| Space r r | Save, compile, run all cases, and show failures/diffs (matches nvf) |
| Space r p | Receive a new C++ problem and samples (matches nvf) |
| Space r n | Rename symbol (Helix's former Space r action) |
| Space t c | Save and import samples into the current solution |

Testcase names match CompetiTest.nvim's default multi-file naming:
`task_input0.txt`, `task_output0.txt`, etc. Open and edit these in Helix with
`:open task_input0.txt` and `:open task_output0.txt` or the file picker.
Delete a numbered case with `hxct delete SOURCE NUMBER` in a terminal.
Deletion cannot be undone.

For problem import, install the Competitive Companion browser extension, press
Space r p and then press its button for the problem page. This creates a
`<problem-name>.cpp` in Helix's working directory, using
`~/Documents/codeforces/template.cpp` if present, and adds the samples.
It refuses to overwrite an existing source. Open the printed path in Helix.
Space t c instead appends samples to an existing source file. Both commands
listen at loopback port 27121 for 60 seconds; from a terminal use
`hxct receive-problem --port 27122 --timeout 120` for another port.

In a terminal: `hxct add SOURCE --input '2 3' --output '5'`,
`hxct run SOURCE --diff`, `hxct run SOURCE --exact` (byte comparison),
or `hxct run SOURCE --timeout 2`. Default comparison ignores whitespace
differences and each case has a five-second limit. Compilers (gcc/g++,
rustc, javac/java) must be on PATH. Run only code and payloads you trust.

Not implemented: Neovim popup/split UI, single-file msgpack conversion,
no-recompile mode, per-folder Lua config, custom compile commands, and
automatic creation of entire contests or interactive path/extension prompts.
