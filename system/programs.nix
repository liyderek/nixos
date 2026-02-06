{ pkgs, inputs, ... }:
{
  programs = {
    # hyprland
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };

    zsh.enable = true;

    # nix ld
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        libjpeg
        libjpeg8
        libpng
        fontconfig
        freetype
        libxml2
        glib
        glibc
        libz
      ];
    };

    virt-manager.enable = true;
  };
}
