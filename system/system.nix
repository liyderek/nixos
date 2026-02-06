{
  pkgs,
  inputs,
  ...
}: {
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  system.stateVersion = "24.11";

  boot = {
    kernel = {
      # dont change

      sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };

      sysctl."kernel.perf_event_paranoid" = 2;
      sysctl."kernel.kptr_restrict" = 0;
    };
  };

  systemd.services.tailscale-udp-gro = {
    description = "Enable UDP GRO forwarding for Tailscale";
    wantedBy = ["multi-user.target"];
    serviceConfig.ExecStart = ''
      ${pkgs.ethtool}/bin/ethtool -K enp2s0 rx-udp-gro-forwarding on rx-gro-list off
    '';
  };
}
