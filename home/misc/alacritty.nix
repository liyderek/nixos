{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = {
      font = {
        normal = {
          family = "Maple Mono NF";
          style = "Regular";
        };
        bold = {
          family = "Maple Mono NF";
          style = "Bold";
        };
        italic = {
          family = "Maple Mono NF";
          style = "Italic";
        };
        size = 12;
      };
    };
  };
}
