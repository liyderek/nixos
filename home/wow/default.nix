{ lib, pkgs, ... }:
let
in
# ascension-launcher = import ./package.nix { inherit lib pkgs; };
{
  # home.packages = [
  #   ascension-launcher
  # ];

  home.file.".ascension/app.AppImage" = {
    source = pkgs.fetchurl {
      url = "https://api.ascension.gg/api/bootstrap/launcher/latest?unix";
      sha256 = "sha256-Ul67zJFpdLXeT5d0RC2ZyEeyQQBtQkYqoLykT4aVNCU=";
    };
  };
}
