{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  programs.niri = {
    enable = true;
    settings = {
      input = {
        keyboard.xkb.layout = "us,cn";
        keyboard.xkb.options = "grp:alt_caps_toggle";
        keyboard.mod-key = "Super";
        mouse.natural-scroll = true;
        touchpad.natural-scroll = true;
      };

      outputs = {
        "DP-1" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 179.952;
          };
          pos = {
            x = 0;
            y = 0;
          };
        };
        "HDMI-A-1" = {
          mode = {
            width = 3840;
            height = 2160;
            refresh = 60.0;
          };
          pos = {
            x = 2560;
            y = 0;
          };
          scale = 1.5;
        };
        "eDP-1".exclude = true;
      };

      layout = {
        gaps = 0;
        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };
        border = {
          enable = true;
          width = 1;
          active.color = "#7C6F64";
          inactive.color = "#665C54";
        };
      };

      spawn-at-startup = [
        {command = ["nm-applet"];}
        {command = ["wl-clip-persist" "--clipboard" "both"];}
        {command = ["swaybg" "-m" "fill" "-i" "/etc/nixos/wallpapers/wallpaper.png"];}
        {command = ["waybar"];}
        {command = ["swaync"];}
        {command = ["wl-paste" "--type" "image" "--watch" "cliphist" "store"];}
        {command = ["wl-paste" "--type" "text" "--watch" "cliphist" "store"];}
        {command = ["fcitx5" "-d" "-r"];}
      ];

      binds = with config.lib.niri.actions; {
        "Mod+F1".action = spawn "show-keybinds";
        "Mod+Return".action = spawn "kitty";
        "Mod+Shift+Return".action = spawn "kitty" "--title" "float_kitty";
        "Mod+B".action = spawn "floorp";
        "Mod+Q".action = close-window;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+Space".action = toggle-window-floating;
        "Mod+D".action = spawn "rofi" "-show" "drun";
        "Mod+Shift+D".action = spawn "discord" "--enable-features=UseOzonePlatform" "--ozone-platform=wayland";
        "Mod+Shift+S".action = spawn "spotify" "--enable-features=UseOzonePlatform" "--ozone-platform=wayland";
        "Mod+Escape".action = spawn "hyprlock";
        "Mod+Shift+Escape".action = spawn "shutdown-script";
        "Mod+E".action = spawn "thunar";
        "Mod+Shift+B".action = spawn "pkill" "-SIGUSR1" ".waybar-wrapped";
        "Mod+C".action = spawn "hyprpicker" "-a";
        "Mod+H".action = spawn "chromium" "--gtk-version=4";
        "Mod+W".action = spawn "wallpaper-picker";
        "Mod+R".action = spawn "rofi" "-show" "drun";

        "Mod+Print".action = spawn "grimblast" "--notify" "--freeze" "save" "area";
        "Print".action = spawn "grimblast" "--notify" "--freeze" "copy" "area";

        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        "Mod+Up".action = focus-window-up;
        "Mod+Down".action = focus-window-down;

        "Mod+Shift+Left".action = move-column-left;
        "Mod+Shift+Right".action = move-column-right;
        "Mod+Shift+Up".action = move-window-up;
        "Mod+Shift+Down".action = move-window-down;

        "Mod+Ctrl+Left".action = set-column-width "-10%";
        "Mod+Ctrl+Right".action = set-column-width "+10%";
        "Mod+Ctrl+Up".action = set-window-height "-10%";
        "Mod+Ctrl+Down".action = set-window-height "+10%";

        "Mod+1".action = focus-workspace "1";
        "Mod+2".action = focus-workspace "2";
        "Mod+3".action = focus-workspace "3";
        "Mod+4".action = focus-workspace "4";
        "Mod+5".action = focus-workspace "5";
        "Mod+6".action = focus-workspace "6";
        "Mod+7".action = focus-workspace "7";
        "Mod+8".action = focus-workspace "8";
        "Mod+9".action = focus-workspace "9";
        "Mod+0".action = focus-workspace "10";

        "Mod+Shift+1".action = move-column-to-workspace "1";
        "Mod+Shift+2".action = move-column-to-workspace "2";
        "Mod+Shift+3".action = move-column-to-workspace "3";
        "Mod+Shift+4".action = move-column-to-workspace "4";
        "Mod+Shift+5".action = move-column-to-workspace "5";
        "Mod+Shift+6".action = move-column-to-workspace "6";
        "Mod+Shift+7".action = move-column-to-workspace "7";
        "Mod+Shift+8".action = move-column-to-workspace "8";
        "Mod+Shift+9".action = move-column-to-workspace "9";
        "Mod+Shift+0".action = move-column-to-workspace "10";

        "XF86AudioRaiseVolume".action = spawn "pamixer" "-i" "2";
        "XF86AudioLowerVolume".action = spawn "pamixer" "-d" "2";
        "XF86AudioMute".action = spawn "pamixer" "-t";
        "XF86AudioPlay".action = spawn "playerctl" "play-pause";
        "XF86AudioNext".action = spawn "playerctl" "next";
        "XF86AudioPrev".action = spawn "playerctl" "previous";

        "XF86MonBrightnessUp".action = spawn "brightnessctl" "set" "5%+";
        "XF86MonBrightnessDown".action = spawn "brightnessctl" "set" "5%-";
        "Mod+V".action = spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";
      };

      window-rules = [
        {
          matches = [{title = "float_kitty";}];
          open-floating = true;
        }
      ];
    };
  };

  home.packages = with pkgs; [
    swaybg
    networkmanagerapplet
    wl-clip-persist
    pamixer
    playerctl
    brightnessctl
  ];

  programs.noctalia = {
    enable = true;
    settings = {
      # theme = {
      #   mode = "dark";
      #   source = "builtin";
      #   builtin = "Catppuccin";
      # };
    };
  };
}

