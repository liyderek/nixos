_: {
  configurations.nixos.nixos.module = { config, lib, pkgs, ... }: {
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

    # The kernel module aggregator now reads a .ko.cer for every external
    # module. VMware installs unsigned modules without those files.
    boot.extraModulePackages = lib.mkForce [
      (config.boot.kernelPackages.vmware.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          for module in "$out"/lib/modules/*/misc/{vmmon,vmnet}.ko; do
            touch "$module.cer"
          done
        '';
      }))
    ];

    security.pki.certificateFiles = [ ./rootCA.pem ];
    services.flatpak.packages = [ "gg.minion.Minion" ];
    system.stateVersion = "24.11";
  };
}
