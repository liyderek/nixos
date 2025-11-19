{ lib, pkgs, ... }:
let
  i3statusConf = ''
    #      .-.     .-.     .-.     .-.     .-.     .-.     .-.     .-.     .-.
    # `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'
    #
    # github.com/rafi i3status config
    #
    # Uses the 'termsyn.icons' font at http://sourceforge.net/projects/termsyn

    general {
    	output_format = "i3bar"
    	colors = true
    	color_good = "#888888"
    	color_bad = "#CC1616"
    	color_degraded = "#55858E"
    	interval = 3
    }

    order += "volume master"
    order += "load"
    order += "cpu_usage"
    order += "cpu_temperature 0"
    order += "cpu_temperature 1"
    order += "cpu_temperature 2"
    order += "cpu_temperature 3"
    order += "disk /"
    order += "disk /mnt/media"
    order += "ethernet enp5s0"
    order += "tztime local"
    #order += "ipv6"
    #order += "run_watch DHCP"
    #order += "run_watch VPN"
    #order += "wireless wlan0"

    volume master {
    	device = "default"
    	mixer = "Master"
    	mixer_idx = 0
    	format = " í %volume "
    	format_muted = " ë muted (%volume) "
    }

    load {
    	format = " Î %1min"
    }

    cpu_usage {
    	format = "%usage "
    }

    cpu_temperature 0 {
    	format = " ± %degrees°"
    	path = "/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp2_input"
    	max_threshold = 95
    }

    cpu_temperature 1 {
    	format = "%degrees°"
    	path = "/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp3_input"
    	max_threshold = 95
    }

    cpu_temperature 2 {
    	format = "%degrees°"
    	path = "/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp4_input"
    	max_threshold = 95
    }

    cpu_temperature 3 {
    	format = "%degrees° "
    	path = "/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp5_input"
    	max_threshold = 95
    }

    disk "/" {
    	format = " ¨ /:%avail "
    }

    disk "/mnt/media" {
    	format = " ¨ /mnt/media:%avail "
    }

    wireless wlan0 {
    	format_up = " W: (%quality at %essid) %ip "
    	format_down = " ☡ WiFi "
    }

    ethernet enp0s25 {
    	# if you use %speed, i3status requires root privileges
    	format_up =  " µ %ip "
    	format_down = " Ð eth "
    }

    run_watch DHCP {
    	pidfile = "/var/run/dhcpcd*.pid"
    }

    run_watch VPN {
    	pidfile = "/var/run/vpnc/pid"
    }

    tztime local {
    	format = " %h-%d É %H:%M  ¸ ÈÈÈ È "
    }

    #-------8<---------------------------------------------------------------------
  '';
in
{
  wayland.windowManager.sway =
    let
      # Colors
      active = "#536B3D";
      border = "#313A28";
      text = "#BBC5B2";
      text2 = "#8f8f8f";
      text3 = "#8faf9f";
      bright = "#A3D572";
      bright2 = "#3F5030";
      bg = "#2c2c2e";
      bg2 = "#4c4c4f";

      orange = "#FCBF69";
      blue = "#98CBFE";
      dblue = "#6095C5";
      ia = "#8f8f8f";
      be = "#8faf9f";
      yw = "#ccdc90";
      gn = "#97A824";
      rd = "#e89393";
    in
    {
      enable = true;
      config = rec {
        modifier = "Mod4";
        terminal = "alacritty";

        input = {
          "*" = {
            natural_scroll = "enabled";
          };
        };

        keybindings =
          let
            mod = modifier;
          in
          {
            "${mod}+1" = "workspace 1";
            "${mod}+2" = "workspace 2";
            "${mod}+3" = "workspace 3";
            "${mod}+4" = "workspace 4";
            "${mod}+5" = "workspace 5";
            "${mod}+6" = "workspace 6";
            "${mod}+7" = "workspace 7";
            "${mod}+8" = "workspace 8";
            "${mod}+9" = "workspace 9";

            "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun";
            "${mod}+q" = "kill";
            "${mod}+Left" = "workspace prev_on_output";
            "${mod}+Right" = "workspace next_on_output";
          };

        workspaceOutputAssign = [
          {
            workspace = "1";
            output = "DP‑1";
          }
          {
            workspace = "2";
            output = "DP‑1";
          }
          {
            workspace = "3";
            output = "DP‑1";
          }
          {
            workspace = "4";
            output = "DP‑1";
          }
          {
            workspace = "5";
            output = "DP‑1";
          }
          {
            workspace = "6";
            output = "HDMI‑A‑1";
          }
          {
            workspace = "7";
            output = "HDMI‑A‑1";
          }
          {
            workspace = "8";
            output = "HDMI‑A‑1";
          }
          {
            workspace = "9";
            output = "HDMI‑A‑1";
          }
        ];

        # Monitor layout
        output = {
          # Left monitor: 1440p
          "DP-1" = {
            mode = "2560x1440@179.952Hz"; # adjust if refresh rate differs
            scale = "1";
            position = "0 0"; # vertically center relative to 4k (2160p)
          };

          # Right monitor: 4K (scaled 2x)
          "HDMI-A-1" = {
            mode = "3840x2160@60Hz";
            scale = "1.5";
            position = "2560 0"; # place to the right of the 1440p monitor
          };
        };

        bars = [
          {
            position = "top";
            statusCommand = "i3status -c ~/.config/i3status/config";
            fonts = {
              names = [
                "termsyn-icon"
              ];
              size = 11.0;
              style = "Regular";
            };
            colors = {
              background = "#202023";
              statusline = "#888888";
              separator = "#444448";
              focusedWorkspace = {
                border = gn;
                background = bg;
                text = gn;
              };

              activeWorkspace = {
                border = bg;
                background = bg;
                text = gn;
              };

              inactiveWorkspace = {
                border = bg;
                background = bg;
                text = ia;
              };

              urgentWorkspace = {
                border = rd;
                background = bg;
                text = orange;
              };
            };
          }
        ];

        startup = [
          { command = "firefox"; }
        ];
      };
    };

  programs.i3status = {
    enable = true;
  };

  xdg.configFile."i3status/config".text = lib.mkForce i3statusConf;
}
