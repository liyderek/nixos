{ pkgs, ... }:
{
  xdg.desktopEntries = {
    # renderdoc = {
    #   name = "Renderdoc";
    #   genericName = "renderdoc";
    #   exec = "env -u WAYLAND_DISPLAY distrobox-enter fedora -- qrenderdoc";
    #   terminal = false;
    #   categories = [ "Application" ];
    # };
    codium = {
      name = "VSCodium";
      genericName = "Text Editor";
      exec = "codium --ozone-platform-hint=auto %F";
      icon = "vscodium";
      keywords = [ "vscode" ];
      categories = [
        "Utility"
        "TextEditor"
        "Development"
        "IDE"
      ];
      startupNotify = true;
      startupWMClass = "vscodium";
      type = "Application";
      version = "1.4";
    };
  };
}
