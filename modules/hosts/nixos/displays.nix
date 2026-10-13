_: {
  configurations.homeManager.nixos.module = {
    my.displays = {
      niri = ''
        output "DP-1" {
          mode "2560x1440@179.952"
          position x=0 y=0
        }
        output "HDMI-A-1" {
          mode "3840x2160@60"
          position x=2560 y=0
          scale 1.5
        }
        output "eDP-1" { off; }

        workspace "fun" { open-on-output "DP-1"; }
        workspace "code" { open-on-output "DP-1"; }
        workspace "math" { open-on-output "DP-1"; }
        workspace "aux" { open-on-output "DP-1"; }
        workspace "music" { open-on-output "DP-1"; }
      '';
      swayOutputs = {
        "DP-1" = {
          mode = "2560x1440@179.952Hz";
          scale = "1";
          position = "0 0";
        };
        "HDMI-A-1" = {
          mode = "3840x2160@60Hz";
          scale = "1.5";
          position = "2560 0";
        };
      };
      swayWorkspaceOutputs = [
        {
          workspace = "1 ê";
          output = "DP-1";
        }
        {
          workspace = "2 ý";
          output = "DP-1";
        }
        {
          workspace = "3 Ç";
          output = "DP-1";
        }
        {
          workspace = "4 Â";
          output = "DP-1";
        }
        {
          workspace = "5 ¨";
          output = "DP-1";
        }
        {
          workspace = "6 ©";
          output = "HDMI-A-1";
        }
        {
          workspace = "7 ©";
          output = "HDMI-A-1";
        }
        {
          workspace = "8 ©";
          output = "HDMI-A-1";
        }
      ];
    };
  };
}
