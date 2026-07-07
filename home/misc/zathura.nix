{pkgs, ...}: {
  programs.zathura = {
    enable = true;

    options = {
      # Automatically invert PDF colors for dark mode
      recolor = true;

      # Official Tomorrow Night Palette Constants
      recolor-lightcolor = "#1D1F21"; # Background (base00)
      recolor-darkcolor = "#C5C8C6"; # Foreground text (base05)

      # UI Elements styled for Tomorrow Night
      default-bg = "#1D1F21"; # Window background
      default-fg = "#C5C8C6"; # Window text
      statusbar-bg = "#282A2E"; # Status bar background (base01)
      statusbar-fg = "#B4B7B4"; # Status bar text (base04)
      inputbar-bg = "#1D1F21"; # Command input background
      inputbar-fg = "#F0C674"; # Command prompt text (base0A/Yellow)

      # Highlights and Hints
      highlight-color = "#373B41"; # Selection background (base02)
      highlight-fg = "#B5BD68"; # Selection text (base0B/Green)
      notification-bg = "#282A2E"; # Toast notifications
      notification-fg = "#81A2BE"; # Notification text (base0D/Blue)

      # Sync clipboard when highlighting
      selection-clipboard = "clipboard";
    };

    mappings = {
      "d" = "recolor"; # Press 'd' to toggle dark mode on/off
    };
  };
}
