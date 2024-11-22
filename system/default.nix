{ pkgs, ... }:
{
  imports = [
    ./gnome.nix
    ./polkit.nix
    ./chinese.nix
    ./distrobox.nix
    ./binfmt.nix
  ];

  nixpkgs.overlays = [
    (import ./asahiwidevine.nix)
  ];
}
