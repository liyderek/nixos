{
  lib,
  config,
  pkgs,
  ...
}:
let
  variant = "mocha";
  accent = "mauve";
  catppuccinKvantum = pkgs.catppuccin-kvantum.override {
    inherit variant accent;
  };
  catppuccinTheme = "catppuccin-${variant}-${accent}";
  gtkTheme = pkgs.catppuccin-gtk.override {
    inherit variant;
    accents = [ accent ];
    size = "compact";
  };
in
lib.mkIf (config.my.desktopProfile == "fun") {
  home.packages = [ catppuccinKvantum ];

  gtk = {
    enable = true;
    gtk2.force = true;
    theme = {
      name = lib.mkForce "${catppuccinTheme}-compact";
      package = lib.mkForce gtkTheme;
    };
    iconTheme = {
      name = lib.mkForce "Papirus-Dark";
      package = lib.mkForce pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = lib.mkForce "Bibata-Modern-Classic";
      package = lib.mkForce pkgs.bibata-cursors;
      size = lib.mkForce 24;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "kvantum";
  };

  home.pointerCursor = {
    name = lib.mkForce "Bibata-Modern-Classic";
    package = lib.mkForce pkgs.bibata-cursors;
    size = lib.mkForce 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables.ADW_COLOR_SCHEME = "prefer-dark";

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  xdg.configFile = {
    "gtk-4.0/assets" = {
      force = true;
      source = "${gtkTheme}/share/themes/${catppuccinTheme}-compact/gtk-4.0/assets";
    };
    "gtk-4.0/gtk.css" = {
      force = true;
      source = "${gtkTheme}/share/themes/${catppuccinTheme}-compact/gtk-4.0/gtk.css";
    };
    "gtk-4.0/gtk-dark.css" = {
      force = true;
      source = "${gtkTheme}/share/themes/${catppuccinTheme}-compact/gtk-4.0/gtk-dark.css";
    };
    "Kvantum/${catppuccinTheme}".source = "${catppuccinKvantum}/share/Kvantum/${catppuccinTheme}";
    "Kvantum/kvantum.kvconfig" = {
      force = true;
      source = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
        General.theme = catppuccinTheme;
      };
    };
  };
}
