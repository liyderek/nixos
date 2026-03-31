{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.my.desktopProfile == "fun") {
  programs.waybar = {
    enable = true;
    settings = lib.mkForce {
      mainBar = {
        layer = "top";
        position = "top";
        mode = "dock";
        height = 36;
        margin-top = 10;
        margin-left = 10;
        margin-right = 10;
        spacing = 6;

        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "pulseaudio"
          "network"
          "tray"
          "battery"
        ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          active-only = false;
          on-click = "activate";
          persistent-workspaces = {
            "*" = [
              1
              2
              3
              4
              5
              6
              7
              8
              9
              10
            ];
          };
        };

        clock = {
          format = "{:%a %d %b %R}";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            on-scroll = 1;
          };
        };

        network = {
          format-wifi = "󰤨 Wi-Fi";
          format-ethernet = "󱘖 Wired";
          format-linked = "󰤪 Secure";
          format-disconnected = "󰤮 Off";
          format-alt = "󰤨 {signalStrength}%";
          tooltip-format = "󱘖 {ipaddr}  {bandwidthUpBytes}  {bandwidthDownBytes}";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "";
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol -t 3";
          scroll-step = 4;
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
        };

        tray = {
          icon-size = 14;
          spacing = 6;
        };

        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 20;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };
      };
    };

    style = lib.mkForce ''
      * {
        font-family: "Maple Mono NF", monospace;
        font-size: 14px;
        margin: 0;
        padding: 0;
      }

      @define-color base #1e1e2e;
      @define-color mantle #181825;
      @define-color surface0 #313244;
      @define-color text #cdd6f4;
      @define-color blue #89b4fa;
      @define-color mauve #cba6f7;
      @define-color green #a6e3a1;
      @define-color yellow #f9e2af;
      @define-color red #f38ba8;

      window#waybar {
        background: transparent;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: @base;
        border: 1px solid @surface0;
        border-radius: 11px;
      }

      .modules-left {
        padding: 0 10px 0 6px;
      }

      .modules-center {
        padding: 0 8px;
      }

      .modules-right {
        padding: 0 12px;
      }

      #workspaces button {
        color: @text;
        border-radius: 10px;
        padding: 0 6px;
      }

      #workspaces button.active {
        color: @mauve;
        background: @surface0;
      }

      #clock {
        color: @yellow;
      }

      #pulseaudio {
        color: @mauve;
      }

      #network {
        color: @blue;
      }

      #battery {
        color: @green;
      }

      #battery.critical:not(.charging) {
        color: @red;
      }
    '';
  };

  programs.waybar.package = pkgs.waybar.overrideAttrs (old: {
    mesonFlags = (old.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
  });
}
