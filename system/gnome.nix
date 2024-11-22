{ pkgs, ... }:
{
    services.xserver.desktopManager.gnome.enable = true;
    programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.gnome.seahorse.out}/libexec/seahorse/ssh-askpass";
}
