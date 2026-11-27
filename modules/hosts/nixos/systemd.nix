_: {
  configurations.nixos.nixos.module =
    { lib, pkgs, ... }:
    {
      systemd.user.services.kanshi = {
        description = "kanshi daemon";
        environment = {
          WAYLAND_DISPLAY = "wayland-1";
          DISPLAY = ":0";
        };
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.kanshi}/bin/kanshi -c kanshi_config_file";
        };
      };
      systemd.user.services.seanime = {
        description = "Seanime Media Server";
        wantedBy = [ "default.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.seanime}/bin/seanime";
          Restart = "on-failure";
          RestartSec = 5;
        };

        path = with pkgs; [
          ffmpeg-full
          mpv
        ];
      };
      systemd.user.services.seanime-tailscale-serve = {
        description = "Serve Seanime privately on the tailnet";
        wantedBy = [ "default.target" ];
        after = [ "seanime.service" ];
        requires = [ "seanime.service" ];

        serviceConfig = {
          ExecStart = "${pkgs.tailscale}/bin/tailscale serve --yes --bg=false --https=43211 http://127.0.0.1:43211";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
}
