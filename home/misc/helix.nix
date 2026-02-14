{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    settings.theme = "sakura-dark";

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
      ];

      language-server = {
        svelte-language-server = {
          command = "${pkgs.nodePackages.svelte-language-server}/bin/svelteserver";
          args = [ "--stdio" ];
        };
        typescript-language-server = {
          command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
          args = [ "--stdio" ];
        };
      };
    };
  };

  xdg.configFile."helix/themes/sakura-dark.toml".text = ''
    inherits = "github_dark"

    "ui.background" = { bg = "bg" }
    "ui.statusline" = { fg = "fg", bg = "bg_alt" }
    "ui.statusline.inactive" = { fg = "muted", bg = "bg_alt" }
    "ui.cursor" = { fg = "bg", bg = "accent" }
    "ui.selection" = { bg = "selection" }
    "ui.linenr" = { fg = "muted" }
    "ui.linenr.selected" = { fg = "accent" }
    "comment" = { fg = "muted", modifiers = [ "italic" ] }
    "keyword" = { fg = "accent" }
    "string" = { fg = "petal" }
    "type" = { fg = "accent_2" }
    "function" = { fg = "accent_2" }
    "tag" = { fg = "accent" }
    "markup.tag" = { fg = "accent" }
    "tag.delimiter" = { fg = "muted" }
    "markup.attribute" = { fg = "accent_2" }
    "attribute" = { fg = "accent_2" }
    "operator" = { fg = "sa2" }
    "constant" = { fg = "gp1" }
    "number" = { fg = "gp0" }

    [palette]
    bg = "#191719"
    bg_alt = "#252326"
    fg = "#d6c1c5"
    muted = "#b1989c"
    accent = "#c58ea7"
    accent_2 = "#a372ad"
    petal = "#878fb8"
    selection = "#362e35"
    gp0 = "#9e97cf"
    gp1 = "#847db5"
    sa2 = "#8e5c73"
  '';

  home.packages = with pkgs; [
    helix
    nodePackages.svelte-language-server
    nodePackages.typescript-language-server
    nodePackages.typescript
  ];
}
