{ ... }:
let
  custom = {
    font = "Maple Mono NF";
    font_size = "14px";
    font_weight = "normal";
    text_color = "#ebdbb2";
    secondary_accent = "98971a";
    tertiary_accent = "d79921";
    background = "1d2021";
    opacity = "1.0";
  };
in
{
  programs.waybar.style = ''

    * {
        border: none;
        border-radius: 0px;
        padding: 0;
        margin: 0;
        min-height: 0px;
        font-family: ${custom.font};
        font-weight: ${custom.font_weight};
        opacity: ${custom.opacity};
    }

    window#waybar {
        background: rgba(29, 32, 33, 1.00);
    }

    #workspaces {
        font-size: 16px;
        padding-left: 15px;

    }
    #workspaces button {
        color: ${custom.text_color};
        padding-left:  6px;
        padding-right: 6px;
    }
    #workspaces button.empty {
        color: #a89984;
    }
    #workspaces button.active {
        color: #ebdbb2;
    }

    #tray, #pulseaudio, #network, #cpu, #memory, #disk, #clock, #battery, #custom-notification {
        font-size: ${custom.font_size};
        color: ${custom.text_color};
    }

    #cpu {
        padding-left: 15px;
        padding-right: 9px;
        margin-left: 7px;
    }
    #memory {
        padding-left: 9px;
        padding-right: 9px;
    }
    #disk {
        padding-left: 9px;
        padding-right: 15px;
    }

    #tray {
        padding: 0 20px;
        margin-left: 7px;
    }

    #pulseaudio {
        padding-left: 15px;
        padding-right: 9px;
        margin-left: 7px;
    }
    #battery {
        padding-left: 9px;
        padding-right: 9px;
    }
    #network {
        padding-left: 9px;
        padding-right: 30px;
    }

    custom-notification {
        padding-left: 20px;
        padding-right: 20px;
    }

    #clock {
        padding-left: 9px;
        padding-right: 15px;
    }

    #custom-launcher {
        font-size: 20px;
        color: #ebdbb2;
        font-weight: ${custom.font_weight};
        padding-left: 10px;
        padding-right: 15px;
    }
  '';
}
