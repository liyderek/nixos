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
      pk = "#ff77aa";

      w1 = "1 ê";
      w2 = "2 ý";
      w3 = "3 Ç";
      w4 = "4 Â";
      w5 = "5 ¨";
      w6 = "6 ©";
      w7 = "7 ©";
      w8 = "8 ©";
    in
    {
      enable = true;
      config = rec {
        modifier = "Mod4";
        terminal = "alacritty";

        input = {
          "*" = {
            natural_scroll = "enabled";
            repeat_delay = "300";
            repeat_rate = "30";
          };
        };

        focus.followMouse = false;
        focus.mouseWarping = false;

        startup = [
          {
            command = "mako &";
          }
        ];

        keybindings =
          let
            mod = modifier;
          in
          {
            "${mod}+1" = "workspace ${w1}";
            "${mod}+2" = "workspace ${w2}";
            "${mod}+3" = "workspace ${w3}";
            "${mod}+4" = "workspace ${w4}";
            "${mod}+5" = "workspace ${w5}";
            "${mod}+6" = "workspace ${w6}";
            "${mod}+7" = "workspace ${w7}";
            "${mod}+8" = "workspace ${w8}";

            "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun";
            "${mod}+q" = "kill";
            "${mod}+Left" = "workspace prev_on_output";
            "${mod}+Right" = "workspace next_on_output";

            "${mod}+space" = "floating toggle";
            "${mod}+f" = "fullscreen toggle";

            "${mod}+Shift+d" = "exec discord --enable-features=UseOzonePlatform --ozone-platform=wayland";
            "${mod}+Shift+s" = "exec spotify --enable-features=UseOzonePlatform --ozone-platform=wayland";
            "${mod}+Return" = "exec ${terminal}";
            "${mod}+e" = "exec thunar";

            "${mod}+w" = "exec networkmanager_dmenu";

            # printscreen for screenshots
            "Print" = "exec grim -g \"$(slurp)\" - | wl-copy";
          };

        window = {
          commands = [
            {
              criteria = {
                title = "Game";
              };
              command = "floating enable";
            }
          ];
        };

        workspaceOutputAssign = [
          {
            workspace = w1;
            output = "DP-1";
          }
          {
            workspace = w2;
            output = "DP-1";
          }
          {
            workspace = w3;
            output = "DP-1";
          }
          {
            workspace = w4;
            output = "DP-1";
          }
          {
            workspace = w5;
            output = "DP-1";
          }

          {
            workspace = w6;
            output = "HDMI-A-1";
          }
          {
            workspace = w7;
            output = "HDMI-A-1";
          }
          {
            workspace = w8;
            output = "HDMI-A-1";
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
                "termsynicon.ttf"
              ];
              size = 10.0;
              style = "Regular";
            };
            colors = {
              background = "#202023";
              statusline = "#888888";
              separator = "#444448";
              focusedWorkspace = {
                border = pk;
                background = bg;
                text = pk;
              };

              activeWorkspace = {
                border = bg;
                background = bg;
                text = pk;
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
      };

      extraConfig = ''
        set $w1 1 ê
        set $w2 2 ý
        set $w3 3 Ç
        set $w4 4 Â
        set $w5 5 ¨
        set $w6 6 ©
        set $w7 7 ©
        set $w8 8 ©
        client.focused          #ff77aa #ff77aa #000000 #ff77aa
        client.focused_inactive #aa6688 #aa6688 #000000 #aa6688
        client.unfocused        #663344 #663344 #000000 #663344
        client.urgent           #ff5599 #ff5599 #000000 #ff5599
      '';
    };

  programs.i3status = {
    enable = true;
  };

  xdg.configFile."i3status/config".text = lib.mkForce i3statusConf;

  home.packages = with pkgs; [
    mako
    grim
    slurp
  ];
}
