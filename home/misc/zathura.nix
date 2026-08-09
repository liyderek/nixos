{pkgs, ...}: {
  programs.zathura = {
    enable = true;
    options = {
      recolor = true;
      recolor-keephue = true; # <-- preserves original color hues

      recolor-lightcolor = "#1D1F21";
      recolor-darkcolor = "#C5C8C6";

      default-bg = "#1D1F21";
      default-fg = "#C5C8C6";
      statusbar-bg = "#282A2E";
      statusbar-fg = "#B4B7B4";
      inputbar-bg = "#1D1F21";
      inputbar-fg = "#F0C674";

      highlight-color = "#373B41";
      highlight-fg = "#B5BD68";
      notification-bg = "#282A2E";
      notification-fg = "#81A2BE";

      selection-clipboard = "clipboard";
    };
    mappings = {
      "d" = "recolor";
    };
  };
}
