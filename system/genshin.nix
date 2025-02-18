{ pkgs, ... }:
let
  aagl = import (
    builtins.fetchTarball "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz"
  );
in
{
  imports = [
    aagl.module
  ];

  nix.settings = aagl.nixConfig;
  programs.an-anime-game-launcher.enable = true;
}
