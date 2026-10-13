_: {
  configurations.homeManager.nixosmacbook.module = {
    my.displays = {
      niri = ''
        output "eDP-1" { scale 2; }
        // tiny-dfr owns the Touch Bar; it is not a desktop monitor.
        output "DSI-1" { off; }

        workspace "fun"
        workspace "code"
        workspace "math"
        workspace "aux"
        workspace "music"
      '';
      swayOutputs = {
        "eDP-1".scale = "2";
        "DSI-1".disable = "";
      };
    };
  };
}
