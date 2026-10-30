_: {
  configurations.nixos.nixosmacbook.module = {
    hardware.sensor.iio.enable = true;
  };

  configurations.homeManager.nixosmacbook.module =
    { pkgs, ... }:
    let
      seedDefaults =
        pkgs.writers.writePython3 "wluma-seed-defaults"
          {
            libraries = [ pkgs.python3Packages.pyyaml ];
          }
          ''
            import os
            from pathlib import Path
            import tempfile

            import yaml

            data_home = os.environ.get("XDG_DATA_HOME") or Path.home() / ".local/share"
            state = Path(data_home) / "wluma/eDP-1.yaml"
            maximum = int(Path("/sys/class/backlight/apple-panel-bl/max_brightness")
                          .read_text())
            defaults = {
                "night": 20,
                "dark": 35,
                "dim": 50,
                "normal": 70,
                "bright": 85,
                "outdoors": 100,
            }
            data = (yaml.safe_load(state.read_text()) if state.exists()
                    else {"output_name": "eDP-1", "entries": []})
            known = {entry["lux"] for entry in data["entries"]}
            missing = [
                {"lux": lux, "luma": 0, "brightness": max(1, maximum * percent // 100)}
                for lux, percent in defaults.items() if lux not in known
            ]
            if missing:
                data["entries"].extend(missing)
                state.parent.mkdir(parents=True, exist_ok=True)
                with tempfile.NamedTemporaryFile(mode="w", dir=state.parent,
                                                 delete=False) as temporary:
                    yaml.safe_dump(data, temporary, sort_keys=False)
                os.replace(temporary.name, state)
          '';
    in
    {
      # Asahi exposes the Touch Bar as a raw backlight, which otherwise wins
      # Noctalia's automatic selection over the main panel's platform backlight.
      xdg.configFile."noctalia/90-asahi-brightness.toml".text = ''
        [brightness.monitor.eDP-1]
        backend = "backlight"
        backlight_device = "apple-panel-bl"
      '';

      services.wluma = {
        enable = true;
        systemd.target = "graphical-session.target";
        settings = {
          als.iio = {
            path = "/sys/bus/iio/devices";
            thresholds = {
              "0" = "night";
              "20" = "dark";
              "80" = "dim";
              "250" = "normal";
              "500" = "bright";
              "800" = "outdoors";
            };
          };
          output.backlight = [
            {
              name = "eDP-1";
              path = "/sys/class/backlight/apple-panel-bl";
              # Ambient light only; no screen capture or Touch Bar brightness control.
              capturer = "none";
            }
          ];
        };
      };

      # Supply a starting curve for untrained lighting profiles, then let Wluma
      # replace those defaults as the user adjusts brightness. Run only while
      # Wluma is stopped and retain every existing learned profile.
      systemd.user.services.wluma.Service.ExecStartPre = [ "${seedDefaults}" ];
    };
}
