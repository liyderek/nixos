{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = {
      font = {
        normal = {
          family = "Iosevka NF";
          style = "Regular";
        };
        bold = {
          family = "Iosevka NF";
          style = "Bold";
        };
        italic = {
          family = "Iosevka NF";
          style = "Italic";
        };
        size = 11;
      };
    };
  };
}
