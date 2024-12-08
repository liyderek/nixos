{ pkgs, inputs, ... }:
{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom.d;
    emacs = pkgs.emacs30-pgtk;
  };
}
