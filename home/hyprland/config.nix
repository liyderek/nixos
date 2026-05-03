{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      "$mainMod" = "SUPER";

      # autostart
      exec-once = [
        "systemctl --user import-environment &"
        "hash dbus-update-activation-environment 2>/dev/null &"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &"
        "nm-applet &"
        "wl-clip-persist --clipboard both"
        "swaybg -m fill -i /etc/nixos/wallpapers/wallpaper.png &"
        "hyprctl setcursor macOS 25 &"
        "poweralertd &"
        "waybar &"
        "swaync &"
        "wl-paste --type image --watch cliphist store &"
        "wl-paste --type text --watch cliphist store &"
        "fcitx5 -d -r &"
        "fcitx5-remote -r"
      ];

      env = [
        "XCURSOR_SIZE,25"
      ];

      input = {
        kb_layout = "us,cn";
        kb_options = "grp:alt_caps_toggle";
        numlock_by_default = true;
        follow_mouse = 0;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
        natural_scroll = true;
        repeat_delay = 300;
        repeat_rate = 30;
      };

      general = {
        layout = "dwindle";
        # gaps_in = 8;
        # gaps_out = 10;
        gaps_in = 0;
        gaps_out = 0;

        border_size = 1;
        # "col.active_border" = "rgb(cba6f7) rgb(b4befe) 45deg";
        # "col.inactive_border" = "0xFF6C7086";
        # "col.active_border" = "0xFFD79921";
        "col.active_border" = "0xFF7C6F64";
        "col.inactive_border" = "0xFF665C54";

        allow_tearing = true;
      };

      misc = {
        disable_autoreload = true;
        disable_hyprland_logo = true;
        always_follow_on_dnd = true;
        layers_hog_keyboard_focus = true;
        animate_manual_resizes = false;
        enable_swallow = true;
        focus_on_activate = true;
      };

      dwindle = {
        force_split = 0;
        special_scale_factor = 1.0;
        split_width_multiplier = 1.0;
        use_active_for_splits = true;
        pseudotile = "yes";
        preserve_split = "yes";
      };

      master = {
        new_status = "master";
        special_scale_factor = 1;
      };

      decoration = {
        # rounding = 10;
        rounding = 0;
        # active_opacity = 0.94;
        # inactive_opacity = 0.94;
        # fullscreen_opacity = 1.0;

        blur = {
          enabled = true;
          # enabled = false;
          #           size = 1;
          #           passes = 1;
          size = 5;
          passes = 2;
          # brightness = 1;
          # contrast = 1.4;
          # ignore_opacity = false;
          # noise = 0;
          new_optimizations = true;
          # xray = false;
        };

        shadow = {
          # enabled = true;
          enabled = false;
          ignore_window = true;
          offset = "0 2";
          range = 20;
          render_power = 3;
        };
        #         "col.shadow" = "rgba(00000055)";
      };

      animations = {
        enabled = false;

        bezier = [
          "fluent_decel, 0, 0.2, 0.4, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutCubic, 0.33, 1, 0.68, 1"
          "easeinoutsine, 0.37, 0, 0.63, 1"
          "menu_decel, 0.1, 1, 0, 1"
        ];

        animation = [
          # Windows
          "windowsIn, 1, 3, easeOutCubic, popin 80%" # window open
          "windowsOut, 1, 3, fluent_decel, popin 80%" # window close.
          "windowsMove, 1, 2, easeinoutsine, slide" # everything in between, moving, dragging, resizing.

          # Fade
          "fadeIn, 1, 3, easeOutCubic" # fade in (open) -> layers and windows
          "fadeOut, 1, 2, easeOutCubic" # fade out (close) -> layers and windows
          "fadeSwitch, 0, 1, easeOutCirc" # fade on changing activewindow and its opacity
          "fadeShadow, 1, 10, easeOutCirc" # fade on changing activewindow for shadows
          "fadeDim, 1, 4, fluent_decel" # the easing of the dimming of inactive windows
          "border, 1, 2.7, easeOutCirc" # for animating the border's color switch speed
          "borderangle, 1, 30, fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
          "workspaces, 1, 8, menu_decel, slidefade 10%" # styles: slide, slidevert, fade, slidefade, slidefadevert
        ];
      };

      cursor = {
        no_hardware_cursors = true;
      };

      bind = [
        # show keybinds list
        "$mainMod, F1, exec, show-keybinds"

        # keybindings
        "$mainMod, Return, exec, kitty"
        "$mainMod SHIFT, Return, exec, kitty --title float_kitty"
        "$mainMod, B, exec, hyprctl dispatch exec '[workspace 1 silent] floorp'"
        "$mainMod, Q, killactive,"
        "$mainMod, F, fullscreen, 0"
        "$mainMod SHIFT, F, fullscreen, 1"
        "$mainMod, Space, togglefloating,"
        "$mainMod, D, exec, rofi -show drun"
        "$mainMod SHIFT, D, exec, hyprctl dispatch exec '[workspace 4 silent] discord --enable-features=UseOzonePlatform --ozone-platform=wayland'"
        "$mainMod SHIFT, S, exec, hyprctl dispatch exec '[workspace 5 silent] spotify --enable-features=UseOzonePlatform --ozone-platform=wayland'"
        "$mainMod, Escape, exec, hyprlock"
        "$mainMod SHIFT, Escape, exec, shutdown-script"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, E, exec, thunar"
        "$mainMod SHIFT, B, exec, pkill -SIGUSR1 .waybar-wrapped"
        "$mainMod, C ,exec, hyprpicker -a"
        "$mainMod, H, exec, chromium --gtk-version=4"
        "$mainMod, W,exec, wallpaper-picker"
        "$mainMod SHIFT, W, exec, hyprctl dispatch exec '[float;size 1400 900] mathematica -new-notebook'"
        "$mainMod, R, exec, rofi -show drun"

        # screenshot
        "$mainMod, Print, exec, grimblast --notify --freeze save area ~/Pictures/$(date +'%Y-%m-%d-At-%Ih%Mm%Ss').png"
        ",Print, exec, grimblast --notify --freeze copy area"

        # switch focus
        "$mainMod, left, workspace, -1"
        "$mainMod, right, workspace, +1"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # switch workspace
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # same as above, but switch to the workspace
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1" # movetoworkspacesilent
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
        "$mainMod CTRL, c, movetoworkspace, empty"

        # window control
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"
        "$mainMod CTRL, left, resizeactive, -80 0"
        "$mainMod CTRL, right, resizeactive, 80 0"
        "$mainMod CTRL, up, resizeactive, 0 -80"
        "$mainMod CTRL, down, resizeactive, 0 80"
        "$mainMod ALT, left, moveactive,  -80 0"
        "$mainMod ALT, right, moveactive, 80 0"
        "$mainMod ALT, up, moveactive, 0 -80"
        "$mainMod ALT, down, moveactive, 0 80"

        # media and volume controls
        ",XF86AudioRaiseVolume,exec, pamixer -i 2"
        ",XF86AudioLowerVolume,exec, pamixer -d 2"
        ",XF86AudioMute,exec, pamixer -t"
        ",XF86AudioPlay,exec, playerctl play-pause"
        ",XF86AudioNext,exec, playerctl next"
        ",XF86AudioPrev,exec, playerctl previous"
        ",XF86AudioStop, exec, playerctl stop"
        "$mainMod, mouse_down, workspace, e-1"
        "$mainMod, mouse_up, workspace, e+1"

        # laptop brigthness
        ",XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        "$mainMod, XF86MonBrightnessUp, exec, brightnessctl set 100%+"
        "$mainMod, XF86MonBrightnessDown, exec, brightnessctl set 100%-"

        # clipboard manager
        "$mainMod, V, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"

        "$mainMod, K, setprop, active alpha 0.94"
      ];

      # mouse binding
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      misc = {
        vrr = 1;
      };

    };

    extraConfig = "
      monitor=DP-1, 2560x1440@179.952, 0x0, 1
      monitor=HDMI-A-1, 3840x2160@60, 2560x0, 1.5
      # monitor=eDP-1, preferred, 2560x640, 2
      monitor=eDP-1, disable

      workspace = 1, monitor:DP-1
      workspace = 2, monitor:DP-1
      workspace = 3, monitor:DP-1
      workspace = 4, monitor:DP-1
      workspace = 5, monitor:DP-1
      workspace = 6, monitor:HDMI-A-1
      workspace = 7, monitor:HDMI-A-1
      workspace = 8, monitor:HDMI-A-1

      xwayland {
        force_zero_scaling = true
      }
    ";
  };
}
