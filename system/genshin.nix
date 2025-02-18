{ pkgs, ... }:
let
  aagl = import (
    builtins.fetchTarball {
      url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
      sha256 = "";
    }
  );
in
{
  imports = [
    aagl.module
  ];

  nix.settings = aagl.nixConfig;
  programs.an-anime-game-launcher.enable = true;
}
