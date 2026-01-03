{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true; # This automatically adds the eval hook to .zshrc
  };
}
