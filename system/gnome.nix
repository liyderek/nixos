{ pkgs, ... }:
{
  # Full GNOME desktop disabled — it installs xdg-desktop-portal-gnome
  # which intercepts ScreenCast and blocks PipeWire capture on Niri.
  # services.desktopManager.gnome.enable = true;

  # Keep gnome-keyring for credential/secret storage
  services.gnome.gnome-keyring.enable = true;

  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.seahorse.out}/libexec/seahorse/ssh-askpass";
}
