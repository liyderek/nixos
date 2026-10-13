_: {
  flake.modules.nixos.base = {
    networking = {
      # network
      networkmanager.enable = true;
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      firewall = {
        enable = false;
      };
    };
  };
}
