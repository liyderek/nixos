{ pkgs, ... }:
let
  aagl = import (
    builtins.fetchTarball {
      url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
      sha256 = "0v59frhfnyy7pbmbv7bdzssdp554bjsgmmm4dw31p5askysmlvib";
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
