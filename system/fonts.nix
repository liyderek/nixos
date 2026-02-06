{ pkgs, ... }:
let
  myfont = pkgs.callPackage ../home/misc/termsynicon.nix { };
in
{
  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;
    fontconfig.allowBitmaps = true;
    packages = [
      myfont
    ];
  };

  console = {
    packages = with pkgs; [
      termsyn
    ];
  };
}
