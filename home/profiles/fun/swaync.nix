{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.my.desktopProfile == "fun") {
  home.packages = [ pkgs.swaynotificationcenter ];

  xdg.configFile."swaync/config.json" = {
    force = true;
    source = ../../swaync/config.json;
  };

  xdg.configFile."swaync/style.css" = {
    force = true;
    text = ''
      @define-color base #1e1e2e;
      @define-color mantle #181825;
      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color text #cdd6f4;
      @define-color subtext0 #a6adc8;
      @define-color mauve #cba6f7;

      * {
        font-family: "Maple Mono NF", monospace;
        border-radius: 8px;
      }

      .control-center {
        background: alpha(@base, 0.9);
        border: 1px solid @surface1;
      }

      .notification {
        background: @mantle;
        border: 1px solid @surface0;
        margin: 6px 0;
      }

      .summary {
        color: @text;
        font-size: 16px;
      }

      .body,
      .time {
        color: @subtext0;
        font-size: 14px;
      }

      .widget-title > label {
        color: @text;
        font-size: 20px;
        margin: 18px 10px;
      }

      .widget-title > button {
        color: @mauve;
        background: transparent;
        border: none;
        padding: 7px 3px;
        margin-right: 10px;
      }

      .widget-title > button:hover {
        background: @surface0;
      }

      .widget-dnd > switch:checked,
      .toggle:checked {
        background: @surface1;
      }
    '';
  };
}
