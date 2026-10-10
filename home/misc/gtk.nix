{
  pkgs,
  inputs,
  lib,
  ...
}: {
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.noto
    pkgs.twemoji-color-font
    pkgs.noto-fonts-color-emoji
    pkgs.meslo-lg
    pkgs.symbola
    inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro-nerd
    pkgs.cantarell-fonts
    pkgs.maple-mono.NF
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-cjk-serif
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.monaspace
    pkgs.lmodern
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  xdg.configFile."gtk-3.0/gtk.css".force = true;
  xdg.configFile."gtk-4.0/gtk.css".force = true;

  gtk = {
    enable = true;
    font = {
      name = "Maple Mono NF";
      size = 10;
      package = pkgs.maple-mono.NF;
    };
    theme = {
      name = "catppuccin-mocha-pink-standard";
      package = pkgs.catppuccin-gtk.override {
        size = "standard";
        accents = ["pink"];
        variant = "mocha";
      };
    };
    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme = 1
    '';
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk3.extraCss = ''
      headerbar, .titlebar {
        display: none;
      }
    '';
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraCss = ''
      headerbar, .titlebar {
        display: none;
      }
    '';
    cursorTheme = {
      name = "macOS";
      package = pkgs.apple-cursor;
      size = 25;
    };
  };

  home.pointerCursor = {
    name = "macOS";
    package = pkgs.apple-cursor;
    size = 25;
  };
}
