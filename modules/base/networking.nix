_: {
  flake.modules.nixos.base = {
    networking = {
      # network
      networkmanager.enable = true;
      nameservers = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];

      firewall = {
        enable = false;
      };
    };
  };
}
