{ pkgs, ... }:
{
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc # glibc + libstdc++
    zlib
    libiconv
  ];
}
