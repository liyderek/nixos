_: {
  flake.modules.homeManager.dev = { pkgs, inputs, lib, ... }: {
    imports = [ inputs.helix-plugins.homeManagerModules.default ];

    programs.helix = {
      enable = true;
      package = pkgs.steelix;
      settings.theme = lib.mkForce "catppuccin-mocha-pink-components";
      plugins = with (pkgs.callPackage (inputs.helix-plugins + "/pkgs") { }); [
        scopeline-hx
        forest-hx
        streal-hx
        scooter-hx
        zen-mode-hx
        # Juju 0.3.16 uses push-component! without importing helix/misc.scm.
        (juju.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            substituteInPlace src/view-common.scm \
              --replace-fail '(require-builtin helix/components)' '(require-builtin helix/components)
            (require "helix/misc.scm")'
          '';
        }))
      ];

      settings.editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
      settings.editor.indent-guides.render = true;
      settings.keys.normal."C-S-f" = ":scooter";
      settings.keys.insert."C-S-f" = ":scooter";
      settings.keys.select."C-S-f" = ":scooter";
      settings.keys.normal.space = {
        e = ":forest-open";
        E = ":streal-open";
        o = "file_explorer"; # Keep the built-in explorer displaced from Space e.
      };
      settings.keys.normal.space.r = {
        d = [
          ":write"
          ":debug-start binary-io %sh{hxdbg-io build \"%{buffer_name}\"} %sh{hxdbg-io tty \"%{buffer_name}\"}"
        ];
        g = [
          ":write"
          ":sh hxdbg-gdb \"%{buffer_name}\" 2>&1 || true"
        ];
        r = [
          ":write"
          ":sh hxct run \"%{buffer_name}\" --window 2>&1 || true"
        ];
        p = ":open \"%sh{hxct receive-problem --prompt --path-only}\"";
        P = ":open \"%sh{hxct new --prompt --path-only --misc}\"";
        n = "rename_symbol"; # Space r previously renamed symbols.
      };
      settings.keys.normal.space.G.V = ":dap-variables"; # Keep the built-in Space G v popup.
      settings.keys.normal.space.t = {
        a = [
          ":write"
          ":sh hxct add \"%{buffer_name}\" --window"
        ];
        l = ":sh hxct list \"%{buffer_name}\"";
        c = [
          ":write"
          ":sh hxct receive \"%{buffer_name}\""
        ];
      };

      languages = {
        language = [
          {
            name = "cpp";
            auto-format = true;
            indent = {
              tab-width = 2;
              unit = "  ";
            };
            formatter = {
              command = "${pkgs.llvmPackages_19.clang-tools}/bin/clang-format";
              args = [ "--style={BasedOnStyle: Microsoft, IndentWidth: 2, UseTab: Never}" ];
            };
            debugger = {
              name = "lldb-dap";
              transport = "stdio";
              command = "${inputs.helix-dap-vars.packages.${pkgs.stdenv.hostPlatform.system}.helix-dap-vars}/bin/helix-dap-vars";
              args = [ "--" "${pkgs.llvmPackages_22.lldb}/bin/lldb-dap" ];
              templates = [
                {
                  name = "binary";
                  request = "launch";
                  completion = [ { name = "binary"; completion = "filename"; } ];
                  args = { program = "{0}"; console = "internalConsole"; };
                }
                {
                  name = "binary-io";
                  request = "launch";
                  completion = [
                    { name = "binary"; completion = "filename"; }
                    { name = "terminal"; completion = "filename"; }
                  ];
                  args = { program = "{0}"; stdio = [ "{1}" "{1}" "{1}" ]; };
                }
                {
                  name = "attach";
                  request = "attach";
                  completion = [ "pid" ];
                  args = { pid = "{0}"; console = "internalConsole"; };
                }
              ];
            };
          }
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
          }
          {
            name = "latex";
            language-servers = [ "texlab" ];
          }
          {
            name = "svelte";
            language-servers = [ "svelte-language-server" ];
          }
          {
            name = "typescript";
            language-servers = [ "typescript-language-server" ];
          }
          {
            name = "tsx";
            language-servers = [ "typescript-language-server" ];
          }
          {
            name = "rust";
            auto-format = true;
            formatter = {
              command = "${pkgs.direnv}/bin/direnv";
              args = [
                "exec"
                "."
                "rustfmt"
                "--edition"
                "2024"
              ];
            };
            language-servers = [ "rust-analyzer" ];
          }
        ];

        language-server = {
          texlab.command = "${pkgs.texlab}/bin/texlab";
          svelte-language-server = {
            command = "${pkgs.svelte-language-server}/bin/svelteserver";
            args = [ "--stdio" ];
          };
          typescript-language-server = {
            command = "${pkgs.typescript-language-server}/bin/typescript-language-server";
            args = [ "--stdio" ];
          };
          rust-analyzer = {
            command = "${pkgs.direnv}/bin/direnv";
            args = [
              "exec"
              "."
              "rust-analyzer"
            ];
          };
        };
      };
    };

    xdg.configFile."helix/themes/catppuccin-mocha-pink-components.toml".text = ''
      inherits = "catppuccin-mocha"
      "constructor" = "pink"
    '';

    xdg.configFile."helix/cogs/dap-vars.scm".source = inputs.helix-dap-vars + "/dap-vars.scm";
    # The existing helix.scm is empty; take ownership only of this command file.
    xdg.configFile."helix/helix.scm" = {
      force = true;
      text = ''
        (require "cogs/dap-vars.scm")
        (provide dap-variables)
      '';
    };

    xdg.configFile."helix/init.scm".text = ''
      (require "scopeline/scopeline.scm")
      (require "forest/forest.scm")
      (forest-set-style! 'mini)
      (require "streal/streal.scm")
      (require "scooter/scooter.scm")
      (require "zen-mode/zen-mode.scm")
      (require "juju/juju.scm")
    '';

    catppuccin.helix = {
      enable = true;
      flavor = "mocha";
    };

    home.packages = with pkgs; [
      inputs.helix-dap-vars.packages.${pkgs.stdenv.hostPlatform.system}.helix-dap-vars
      (pkgs.writeShellScriptBin "hxdbg" ''
        export PATH="${pkgs.libnotify}/bin:$PATH"
        exec ${pkgs.bash}/bin/bash ${../../packages/hxdbg.sh} ${pkgs.stdenv.cc}/bin/c++ "$@"
      '')
      (pkgs.writeShellScriptBin "hxdbg-gdb" ''
        export PATH="${pkgs.libnotify}/bin:$PATH"
        program=$(${pkgs.bash}/bin/bash ${../../packages/hxdbg.sh} ${pkgs.stdenv.cc}/bin/c++ "$1") || exit $?
        exec ${pkgs.alacritty}/bin/alacritty --title "Helix C++ Debug" --hold -e ${pkgs.gdb}/bin/gdb -q -ex "break main" -ex run --args "$program"
      '')
      (pkgs.writeShellScriptBin "hxdbg-io" ''
        export PATH="${pkgs.libnotify}/bin:$PATH"
        export HXDBG_BASH=${pkgs.bash}/bin/bash
        export HXDBG_HELPER=${../../packages/hxdbg.sh}
        export HXDBG_COMPILER=${pkgs.stdenv.cc}/bin/c++
        export HXDBG_ALACRITTY=${pkgs.alacritty}/bin/alacritty
        export HXDBG_PYTHON=${pkgs.python3}/bin/python3
        exec ${pkgs.python3}/bin/python3 ${../../packages/hxdbg_io.py} "$@"
      '')
      (pkgs.writeShellScriptBin "hxct" ''
        export PATH="${pkgs.alacritty}/bin:${pkgs.fuzzel}/bin:$PATH"
        exec ${pkgs.python3}/bin/python3 ${../../packages/hxct.py} "$@"
      '')
      texlab
      svelte-language-server
      typescript-language-server
      typescript
      cargo
      rustc
      rustfmt
      rust-analyzer
    ];
  };
}
