{ lib, pkgs, ... }:
let
  ascension-launcher = import ./package.nix { inherit lib pkgs; };
in
{
  home.packages = [
    ascension-launcher
  ];
}
