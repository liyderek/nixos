{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      ${builtins.readFile ./tmux.conf}
      ${builtins.readFile ./tmuxstyle.conf}
    '';
  };
}
