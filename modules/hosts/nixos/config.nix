_: {
  configurations.nixos.nixos.module = { pkgs, ... }: {
    networking.hostName = "nixos";
    networking.firewall = {
      allowedTCPPorts = [
        47984
        47989
        47990
        48010
      ];
      allowedUDPPortRanges = [
        {
          from = 47998;
          to = 48000;
        }
      ];
    };

    # About 16 GiB of logical compressed swap on the 32 GiB desktop.
    # Higher priority keeps the existing 32 GiB /swapfile as overflow.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      priority = 100;
    };
    boot.kernel.sysctl = {
      "vm.swappiness" = 100; # Balance anonymous-page and file-cache reclaim.
      "vm.page-cluster" = 0; # Avoid unnecessary read-ahead on compressed swap.
    };

    virtualisation.vmware.host = {
      enable = true;
      package = pkgs.vmware-workstation.override { enableMacOSGuests = true; };
    };

    security.pki.certificateFiles = [ ./rootCA.pem ];
    services.flatpak.packages = [ "gg.minion.Minion" ];
    system.stateVersion = "24.11";
  };
}
