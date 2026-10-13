_: {
  flake.modules.homeManager.desktop =
    {
      lib,
      config,
      ...
    }:
    lib.mkIf (config.my.desktopProfile == "work") {
    };
}
