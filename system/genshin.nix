{ pkgs, ... }:
let
  aagl = import (
    builtins.fetchTarball {
      url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/release-25.11.tar.gz";
      sha256 = "01nm4qvp6mbyc96ff2paccwcx0clvg1mvpxg5y6d17db9ds7j8kl";
    }
  );
in
{
  imports = [
    aagl.module
  ];

  nix.settings = aagl.nixConfig;
  programs.anime-game-launcher.enable = true;
  programs.anime-games-launcher.enable = true;
  programs.honkers-railway-launcher.enable = true;
  programs.honkers-launcher.enable = true;
  programs.wavey-launcher.enable = true;
  programs.sleepy-launcher.enable = true;
}
