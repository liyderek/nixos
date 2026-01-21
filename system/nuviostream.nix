{ pkgs, ... }:
{
  systemd.services.nuviostream = {
    description = "Nuviostream Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "derek";
      WorkingDirectory = "/home/derek/NuvioStreamsAddon";
      ExecStart = "${pkgs.bash}/bin/bash -lc \"npm start\"";
      Restart = "always";
      Environment = [
        "NODE_ENV=production"
        "PATH=${pkgs.nodejs}/bin:${pkgs.bash}/bin"
      ];
    };
  };
}
