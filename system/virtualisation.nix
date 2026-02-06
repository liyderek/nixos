{ pkgs, ... }:
{
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    libvirtd.qemu.swtpm.enable = true;
    vmware.host.enable = true;
    vmware.host.package = pkgs.vmware-workstation.override { enableMacOSGuests = true; };

    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  users.groups.libvirtd.members = [ "derek" ];
}
