_: {
  flake.modules.homeManager.dev = { pkgs, ... }: {
    programs.helix = {
      enable = true;
      package = pkgs.helix;

      settings.editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
      settings.editor.indent-guides.render = true;
      settings.keys.normal.space.r = {
        r = [
          ":write"
          ":sh hxct run \"%{buffer_name}\" --window 2>&1 || true"
        ];
        p = ":open \"%sh{hxct receive-problem --prompt --path-only}\"";
        n = "rename_symbol"; # Space r previously renamed symbols.
      };
      settings.keys.normal.space.t = {
        a = [
          ":write"
          ":sh hxct add \"%{buffer_name}\""
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

    catppuccin.helix = {
      enable = true;
      flavor = "mocha";
    };

    home.packages = with pkgs; [
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
