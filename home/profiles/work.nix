{
  lib,
  config,
  ...
}:
lib.mkIf (config.my.desktopProfile == "work") {
}
