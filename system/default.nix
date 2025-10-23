{ pkgs, ... }:
{
  imports = [
    ./gnome.nix
    ./polkit.nix
    ./chinese.nix
    ./distrobox.nix
    # ./binfmt.nix
    ./systemd.nix
    ./genshin.nix
    ./sway.nix
    ./mongodb.nix
  ];

  nixpkgs.overlays = [
    # (import ./asahiwidevine.nix)
  ];
}
