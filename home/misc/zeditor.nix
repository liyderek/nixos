{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
      "elixir"
      "make"
      "catppuccin"
    ];
    userSettings = {
      vim_mode = true;
      base_keymap = "VSCode";
      ui_font_size = 16;
      buffer_font_size = 16;
      theme = {
        mode = "system";
        light = "One Light";
        dark = "Catppuccin Mocha";
      };
    };
  };
}
