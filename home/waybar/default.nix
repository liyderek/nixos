{ pkgs, ... }:
{

  imports = [
    ./settings.nix
    ./style.nix
  ];

  programs.waybar = {
    enable = true;
  };

  programs.waybar.package = pkgs.waybar.overrideAttrs (oa: {
    mesonFlags = (oa.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
  });

}
