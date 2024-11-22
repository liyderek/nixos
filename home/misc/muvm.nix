{ pkgs, ... }:
let
  muvm = pkgs.callPackage ./muvmPackage.nix { };
in
{
  home.packages = with pkgs; [
    muvm
  ];
}
