{ pkgs, ... }:
let
  wall-change = pkgs.writeShellScriptBin "wall-change" (builtins.readFile ./scripts/wall-change.sh);
  wallpaper-picker = pkgs.writeShellScriptBin "wallpaper-picker" (
    builtins.readFile ./scripts/wallpaper-picker.sh
  );
  shutdown-script = pkgs.writeScriptBin "shutdown-script" (
    builtins.readFile ./scripts/shutdown-script.sh
  );
  show-keybinds = pkgs.writeScriptBin "show-keybinds" (builtins.readFile ./scripts/keybinds.sh);
in
{
  home.packages = with pkgs; [
    wall-change
    wallpaper-picker

    shutdown-script

    show-keybinds
  ];
}
