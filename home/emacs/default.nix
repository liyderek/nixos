{ pkgs, inputs, ... }:
{
  programs.doom-emacs = {
    enable = true;
    doomDir = inputs.doom-config;
    emacs = pkgs.emacs30-pgtk;
  };
}
