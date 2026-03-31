{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.my.desktopProfile == "fun") {
  home.packages = [ pkgs.hyprlock ];

  wayland.windowManager.hyprland.settings = lib.mkForce {
    "$mainMod" = "SUPER";

    exec-once = [
      "systemctl --user import-environment &"
      "hash dbus-update-activation-environment 2>/dev/null &"
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &"
      "nm-applet &"
      "wl-clip-persist --clipboard both"
      "swaybg -m fill -i $(find ~/Pictures/wallpapers/ -maxdepth 1 -type f) &"
      "hyprctl setcursor Bibata-Modern-Classic 24 &"
      "waybar &"
      "swaync &"
      "wl-paste --type image --watch cliphist store &"
      "wl-paste --type text --watch cliphist store &"
    ];

    env = [
      "XCURSOR_SIZE,24"
    ];

    input = {
      kb_layout = "us,cn";
      kb_options = "grp:alt_caps_toggle";
      numlock_by_default = true;
      follow_mouse = 0;
      sensitivity = 0;
      touchpad.natural_scroll = true;
      repeat_delay = 300;
      repeat_rate = 30;
    };

    general = {
      layout = "dwindle";
      gaps_in = 4;
      gaps_out = 9;
      border_size = 2;
      "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
      "col.inactive_border" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
      no_border_on_floating = false;
    };

    decoration = {
      rounding = 10;
      shadow.enabled = false;
      blur = {
        enabled = true;
        size = 6;
        passes = 2;
        new_optimizations = true;
        ignore_opacity = true;
      };
    };

    animations = {
      enabled = true;
      bezier = [
        "md3_decel, 0.05, 0.7, 0.1, 1"
        "easeOutExpo, 0.16, 1, 0.3, 1"
      ];
      animation = [
        "windows, 1, 3, md3_decel, popin 60%"
        "border, 1, 10, default"
        "fade, 1, 2.5, md3_decel"
        "workspaces, 1, 3.5, easeOutExpo, slide"
      ];
    };

    misc = {
      disable_hyprland_logo = true;
      vrr = 1;
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    layerrule = [
      "blur on, match:namespace rofi"
      "ignore_alpha 0.7, match:namespace rofi"
      "blur on, match:namespace swaync-control-center"
      "blur on, match:namespace swaync-notification-window"
      "ignore_alpha 0.7, match:namespace swaync-control-center"
      "ignore_alpha 0.8, match:namespace swaync-notification-window"
    ];

    # Ported from your sway keybinds, adapted to Hyprland dispatchers.
    bind = [
      "$mainMod, Return, exec, alacritty"
      "$mainMod, D, exec, rofi -show drun"
      "$mainMod, Q, killactive,"
      "$mainMod, Space, togglefloating,"
      "$mainMod, F, fullscreen, 0"
      "$mainMod, E, exec, thunar"
      "$mainMod, left, workspace, -1"
      "$mainMod, right, workspace, +1"
      "$mainMod, W, togglesplit,"
      "$mainMod, S, pseudo,"
      "$mainMod SHIFT, D, exec, discord --enable-features=UseOzonePlatform --ozone-platform=wayland"
      "$mainMod SHIFT, S, exec, spotify --enable-features=UseOzonePlatform --ozone-platform=wayland"
      ",Print, exec, grim -g \"$(slurp)\" - | wl-copy"

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

      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"

      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"
    ];

    binde = [
      ",XF86MonBrightnessDown,exec,${pkgs.brightnessctl}/bin/brightnessctl set 2%-"
      ",XF86MonBrightnessUp,exec,${pkgs.brightnessctl}/bin/brightnessctl set +2%"
      ",XF86AudioLowerVolume,exec,${pkgs.pamixer}/bin/pamixer -d 2"
      ",XF86AudioRaiseVolume,exec,${pkgs.pamixer}/bin/pamixer -i 2"
    ];

    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    windowrulev2 = [
      "float,class:^(pavucontrol)$"
      "float,class:^(nm-connection-editor)$"
      "float,title:^(Picture-in-Picture)$"
      "pin,title:^(Picture-in-Picture)$"
    ];
  };

  wayland.windowManager.hyprland.extraConfig = lib.mkForce ''
    monitor=DP-1, 2560x1440@179.952, 0x0, 1
    monitor=HDMI-A-1, 3840x2160@60, 2560x0, 1.5
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
  '';

  xdg.configFile."hypr/hyprlock.conf" = {
    force = true;
    text = ''
      $mauve = rgb(cba6f7)
      $red = rgb(f38ba8)
      $base = rgb(1e1e2e)
      $text = rgb(cdd6f4)

      general {
        disable_loading_bar = true
        hide_cursor = true
      }

      background {
        monitor =
        path = ~/Pictures/wallpapers/others/galaxy.webp
        color = $base
        blur_passes = 2
      }

      label {
        monitor =
        text = $TIME
        color = $mauve
        font_size = 64
        position = 0, 16
        valign = center
        halign = center
      }

      input-field {
        monitor =
        size = 250, 50
        outline_thickness = 3
        outer_color = $mauve
        inner_color = $base
        font_color = $text
        fail_color = $red
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
        fail_transition = 300
        fade_on_empty = false
        placeholder_text = Password...
        dots_size = 0.2
        dots_spacing = 0.64
        dots_center = true
        position = 0, 140
        halign = center
        valign = bottom
      }
    '';
  };
}
