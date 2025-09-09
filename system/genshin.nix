{ pkgs, ... }:
let
  aagl = import (
    builtins.fetchTarball "https://github.com/ezKEa/aagl-gtk-on-nix/archive/release-25.05.tar.gz"
  );
in
{
  imports = [
    aagl.module
  ];

  nix.settings = aagl.nixConfig;
  programs.anime-game-launcher.enable = true;
  programs.anime-games-launcher.enable = true;
  programs.honkers-railway-launcher.enable = true;
  programs.honkers-launcher.enable = true;
  programs.wavey-launcher.enable = true;
  programs.sleepy-launcher.enable = true;
}
