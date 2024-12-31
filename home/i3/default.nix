{ pkgs, ... }:
{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
  };
}
