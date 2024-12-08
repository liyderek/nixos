{ pkgs, inputs, ... }:
{
  programs.doom-emacs = {
    enable = true;
    doomDir = "./doom.d";
  };
}
