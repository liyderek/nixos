{pkgs, ...}: {
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = {
      font = {
        normal = {
          family = "Terminus";
          style = "Regular";
        };
        bold = {
          family = "Terminus";
          style = "Regular";
        };
        italic = {
          family = "Terminus";
          style = "Regular";
        };
        size = 12;
      };
    };
  };
}
