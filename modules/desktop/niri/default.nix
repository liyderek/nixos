_: {
  flake.modules.homeManager.desktop = { config, pkgs, ... }: {
    home.packages = with pkgs; [
      niri
      swaybg
      networkmanagerapplet
      wl-clip-persist
      pamixer
      playerctl
      brightnessctl
      grim
      slurp
      wf-recorder
      glib
      wayland
    ];

    xdg.configFile."niri/config.kdl".text = ''
           prefer-no-csd

           input {
            keyboard {
             repeat-delay 250
             repeat-rate 40
             xkb {
              layout "us,cn"
              options "grp:alt_caps_toggle"
             }
            }
            mod-key "Super"
            mouse {
             natural-scroll
             accel-speed 0.0
             accel-profile "flat"
            }
            touchpad {
             natural-scroll
            }
           }

           layout {
            focus-ring {
             off
            }
            border {
             width 1
             active-color "#f5c2e7"
             inactive-color "#45475a"
            }
            gaps 0
            struts {
             left 0
             right 0
             top 0
             bottom 0
            }
           }

        ${config.my.displays.niri}

        spawn-at-startup "noctalia"

           binds {
            Mod+F1 { show-hotkey-overlay; }
            Mod+Return { spawn "alacritty"; }
            Mod+T { spawn "alacritty" "-o" "font.normal.family=\"Maple Mono NF\"" "-o" "font.bold.family=\"Maple Mono NF\"" "-o" "font.italic.family=\"Maple Mono NF\"" "-o" "font.bold_italic.family=\"Maple Mono NF\"" "-o" "font.size=24"; }
            Mod+Shift+Return { spawn "alacritty" "--title" "float_alacritty"; }
            Mod+B { spawn "floorp"; }
            Mod+Q { close-window; }
            Mod+F { maximize-column; }
            Mod+Shift+F { fullscreen-window; }
            Mod+Space { toggle-window-floating; }
            Mod+Shift+D { spawn "discord" "--enable-features=UseOzonePlatform" "--ozone-platform=wayland"; }
            Mod+Shift+S { spawn "spotify" "--enable-features=UseOzonePlatform" "--ozone-platform=wayland"; }
            Mod+Escape { spawn "swaylock" "--daemonize"; }
            Mod+Alt+S repeat=false allow-inhibiting=false hotkey-overlay-title="Toggle sleep screen" { spawn "niri-sleep-screen"; }
            Mod+Shift+Escape { spawn "shutdown-script"; }
            Mod+E { spawn "thunar"; }
            Mod+Shift+B { spawn "pkill" "-SIGUSR1" ".waybar-wrapped"; }
            Mod+H { spawn "chromium" "--gtk-version=4"; }
            Mod+W { spawn "wallpaper-picker"; }
            Mod+R { spawn "rofi" "-show" "drun"; }

            Mod+Print { spawn "screenshot" "save"; }
            Print { spawn "screenshot" "copy"; }

            Mod+Left  { focus-column-left; }
            Mod+Right { focus-column-right; }
            Mod+Up    { focus-workspace-up; }
            Mod+Down  { focus-workspace-down; }

            Mod+Shift+Left  { move-column-left; }
            Mod+Shift+Right { move-column-right; }
            Mod+Shift+Up    { move-window-up; }
            Mod+Shift+Down  { move-window-down; }

            Mod+Ctrl+Left  { set-column-width "-10%"; }
            Mod+Ctrl+Right { set-column-width "+10%"; }
            Mod+Ctrl+Up    { set-window-height "-10%"; }
            Mod+Ctrl+Down  { set-window-height "+10%"; }

            Mod+1 { focus-workspace "fun"; }
            Mod+2 { focus-workspace "code"; }
            Mod+3 { focus-workspace "math"; }
            Mod+4 { focus-workspace "aux"; }
            Mod+5 { focus-workspace "music"; }

            Mod+Shift+1 { move-column-to-workspace "fun"; }
            Mod+Shift+2 { move-column-to-workspace "code"; }
            Mod+Shift+3 { move-column-to-workspace "math"; }
            Mod+Shift+4 { move-column-to-workspace "aux"; }
            Mod+Shift+5 { move-column-to-workspace "music"; }

            Mod+V { spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"; }

            // Core Noctalia binds
            Mod+D { spawn-sh "noctalia msg panel-toggle launcher"; }
            Mod+S { spawn-sh "noctalia msg panel-toggle control-center"; }
            Mod+Comma { spawn-sh "noctalia msg settings-toggle"; }

            // Audio & Brightness
            XF86AudioRaiseVolume { spawn-sh "noctalia msg volume-up"; }
            XF86AudioLowerVolume { spawn-sh "noctalia msg volume-down"; }
            XF86AudioMute { spawn-sh "noctalia msg volume-mute"; }
            XF86MonBrightnessUp { spawn-sh "noctalia msg brightness-up"; }
            XF86MonBrightnessDown { spawn-sh "noctalia msg brightness-down"; }
           }

           window-rule {
            clip-to-geometry true
           }

           window-rule {
            match title="float_alacritty"
            open-floating true
            clip-to-geometry true
           }

           window-rule {
             match app-id="dev.noctalia.Noctalia.Settings"
             open-floating true
             default-column-width { fixed 1080; }
             default-window-height { fixed 920; }
           }

        window-rule {
          match app-id=r#"^winboat-.*$"#

          // Forces the window to open in the floating layer instead of tiling
          open-floating true
      }

           animations {
            off
           }

           debug {
          honor-xdg-activation-with-invalid-serial
           }
    '';

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = { };
    };
  };
}
