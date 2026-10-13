_: {
  flake.modules.nixos.base.programs.git = {
    enable = true;
    lfs.enable = true;
  };
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      programs.git = {
        enable = true;
        settings.user = {
          name = "Derek";
          email = "zedikdagod@gmail.com";
        };
      };
    };
}
