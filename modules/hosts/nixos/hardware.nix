_: {
  configurations.nixos.nixos.module =
    {
      pkgs,
      ...
    }:
    {
      fileSystems."/run/media/derek/51D00F980942B197" = {
        device = "/dev/disk/by-uuid/51D00F980942B197";
        fsType = "ntfs";
        options = [
          "uid=1000"
          "gid=1000"
          "dmask=022"
          "fmask=133"
          "exec"
          "nofail"
          "x-systemd.automount"
          "x-systemd.idle-timeout=10min"
        ];
      };

      systemd.services.tailscale-udp-gro = {
        description = "Enable UDP GRO forwarding for Tailscale";
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = ''
          ${pkgs.ethtool}/bin/ethtool -K enp2s0 rx-udp-gro-forwarding on rx-gro-list off
        '';
      };

    };
}
