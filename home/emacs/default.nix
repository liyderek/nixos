{ pkgs, inputs, ... }:
{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom.d;
    emacs = pkgs.emacs29-pgtk;
  };
}
