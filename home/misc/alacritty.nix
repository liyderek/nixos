{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "Maple Mono";
          style = "Regular";
        };
        bold = {
          family = "Maple Mono";
          style = "Bold";
        };
        italic = {
          family = "Maple Mono";
          style = "Italic";
        };
        size = 14;
      };
    };
  };
}
