{ lib, pkgs, ... }:
{
  systemd.services.spotifyd = {
    enable = true;
    description = "A spotify playing daemon";
    documentation = "https://github.com/Spotifyd/spotifyd";
    wants = [
      "network-online.target"
      "sound.target"
    ];
    after = [
      "network-online.target"
      "sound.target"
    ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.spotifyd} --no-daemon";
      Restart = "always";
      RestartSec = 12;
    };
    wantedBy = "default.target";
  };
}
