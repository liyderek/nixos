{ pkgs, inputs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.noto
    pkgs.twemoji-color-font
    pkgs.noto-fonts-emoji
    pkgs.meslo-lg
    pkgs.symbola
    inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd
    pkgs.cantarell-fonts
    pkgs.maple-mono.NF
  ];

  gtk = {
    enable = true;
    font = {
      name = "Maple Mono NF";
      size = 10;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override { color = "black"; };
    };
    theme = {
      name = "Colloid-Green-Dark-Gruvbox";
      package = pkgs.colloid-gtk-theme.override {
        colorVariants = [ "dark" ];
        themeVariants = [ "green" ];
        tweaks = [
          "gruvbox"
          # "rimless"
          # "float"
        ];
      };
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 25;
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 25;
  };
}
