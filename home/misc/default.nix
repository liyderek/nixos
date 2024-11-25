{ pkgs, config, ... }:
{
  imports = [
    ./gtk.nix
    ./kitty.nix
    ./vscodium.nix
    ./rofi.nix
    ./fuzzel.nix
    ./zsh.nix
    ./starship.nix
    ./apps.nix
    ./muvm.nix
    ./git.nix
    ./qt.nix
    ./sway.nix
  ];
}
