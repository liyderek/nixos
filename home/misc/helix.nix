{ pkgs, ... }: {
  programs.helix = {
    enable = true;
    package = pkgs.helix;

    settings.editor.cursor-shape = {
      normal = "block";
      insert = "bar";
      select = "underline";
    };
    settings.editor.indent-guides.render = true;

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
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
    svelte-language-server
    typescript-language-server
    typescript
    cargo
    rustc
    rustfmt
    rust-analyzer
  ];
}
