{
  pkgs,
  inputs,
  config,
  ...
}:
let
  hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
in
{

  imports = [
    (import ./config.nix)
    (import ./hyprlock.nix { inherit pkgs; })
    inputs.hyprland.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    # swww
    swaybg
    inputs.hypr-contrib.packages.${pkgs.system}.grimblast
    hyprpicker
    grim
    slurp
    wl-clip-persist
    wf-recorder
    glib
    wayland
    direnv
  ];

  systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprland;
    xwayland = {
      enable = true;
    };
    systemd.enable = true;
  };

}
