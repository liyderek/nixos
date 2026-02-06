{
  networking = {
    hostName = "nixos";

    # network
    networkmanager.enable = true;
    nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];

    firewall = {
      enable = false;
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
        #{ from = 8000; to = 8010; }
      ];
    };
  }; # Define your hostname.
}
