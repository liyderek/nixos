{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    (import ./gtk.nix { inherit inputs; })
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
    # ./helix.nix
    # ./sway.nix
  ];
}
