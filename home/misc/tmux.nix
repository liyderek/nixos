{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    extraConfig = ''
      ${builtins.readFile ./tmux.conf}
      ${builtins.readFile ./tmuxstyle.conf}
    '';
  };
}
