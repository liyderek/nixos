{ pkgs, ... }:
{
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
}
