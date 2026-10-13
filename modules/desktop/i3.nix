_: {
  flake.modules.homeManager.i3 =
    { pkgs, ... }:
    {
      xsession.windowManager.i3 = {
        enable = true;
        package = pkgs.i3;
      };
    };
}
