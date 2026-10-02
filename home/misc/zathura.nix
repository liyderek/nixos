{pkgs, ...}: {
  programs.zathura = {
    enable = true;
    options = {
      recolor = true;
      # recolor-keephue = true;
      selection-clipboard = "clipboard";
    };
    mappings = {
      "d" = "recolor";
    };
  };

  catppuccin.zathura = {
    enable = true;
    flavor = "mocha";
  };
}
