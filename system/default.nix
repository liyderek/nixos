{ pkgs, ... }:
{
  imports = [
    ./boot.nix
    ./gnome.nix
    ./hardware.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./polkit.nix
    ./programs.nix
    ./chinese.nix
    ./distrobox.nix
    # ./binfmt.nix
    ./systemd.nix
    ./services.nix
    ./security.nix
    ./system.nix
    ./genshin.nix
    ./sway.nix
    ./mongodb.nix
    ./nix-ld.nix
    ./nuviostream.nix
    ./users.nix
    ./virtualisation.nix
    ./fonts.nix
    ./flatpak.nix
  ];

  nixpkgs.overlays = [
    # (import ./asahiwidevine.nix)
  ];
}
