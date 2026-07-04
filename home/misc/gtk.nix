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
  ];

  home.sessionVariables.ADW_COLOR_SCHEME = lib.mkForce "prefer-dark";
  home.sessionVariables.GTK_THEME = lib.mkForce "Adwaita:dark";

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "Maple Mono NF 10";
      document-font-name = "Maple Mono NF 10";
      monospace-font-name = "Maple Mono NF 10";
    };
  };

  gtk = {
    enable = true;
    font = {
      name = "Maple Mono NF";
      size = 10;
      package = pkgs.maple-mono.NF;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override {color = "black";};
    };
    theme = {
      name = lib.mkDefault "Adwaita-dark";
      package = lib.mkDefault pkgs.gnome-themes-extra;
    };
    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme = 1
    '';
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk3.extraCss = ''
      headerbar, .titlebar {
        display: none;
      }
    '';
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
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
