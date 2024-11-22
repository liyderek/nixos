{ pkgs, ... }:
{
  xdg.desktopEntries = {
    renderdoc = {
      name = "Renderdoc";
      genericName = "renderdoc";
      exec = "env -u WAYLAND_DISPLAY distrobox-enter fedora -- qrenderdoc";
      terminal = false;
      categories = [ "Application" ];
    };
  };
}
