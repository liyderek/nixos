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
      ExecStart = "${pkgs.nodejs}/bin/npm start";
      Restart = "always";
      Environment = [
        "NODE_ENV=production"
      ];
    };
  };
}
