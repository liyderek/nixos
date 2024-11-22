{ pkgs, ... }:
{
  imports = [
    ./gnome.nix
    ./polkit.nix
    ./chinese.nix
    ./distrobox.nix
    ./binfmt.nix
    ./systemd.nix
  ];

  nixpkgs.overlays = [
    (import ./asahiwidevine.nix)
  ];
}
