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

    virtualisation.vmware.host = {
      enable = true;
      package = pkgs.vmware-workstation.override { enableMacOSGuests = true; };
    };

    security.pki.certificateFiles = [ ./rootCA.pem ];
    services.flatpak.packages = [ "gg.minion.Minion" ];
    system.stateVersion = "24.11";
  };
}
