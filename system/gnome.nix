{ pkgs, ... }:
{
  services.xserver.desktopManager.gnome.enable = true;
  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.seahorse.out}/libexec/seahorse/ssh-askpass";
}
