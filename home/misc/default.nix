{
  pkgs,
  config,
  inputs,
  ...
}:
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
    # ./muvm.nix
    ./git.nix
    ./qt.nix
    # ./helix.nix
    # ./sway.nix
    ./discord.nix
    ./spotify.nix
    ./tmux.nix
    ./alacritty.nix
  ];
}
