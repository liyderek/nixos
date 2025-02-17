{ pkgs, ... }:
let
  ascension-launcher = import ./package.nix { inherit pkgs; };
in
{
  home.packages = [
    ascension-launcher
  ];
}
