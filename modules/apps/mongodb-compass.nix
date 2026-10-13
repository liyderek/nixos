_: {
  flake.modules.homeManager.apps =
    { lib, pkgs, ... }:
    lib.mkIf (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.mongodb-compass) {
      home.file.".local/share/applications/mongodb-compass.desktop" = {
        text = ''
          [Desktop Entry]
          Name=MongoDB Compass
          Exec=mongodb-compass --password-store=gnome-libsecret --ignore-additional-command-line-flags %U
          Type=Application
          Terminal=false
          Categories=Development
          Icon=mongodb-compass
        '';
      };
    };
}
