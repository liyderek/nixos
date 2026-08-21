{pkgs, ...}: let
  myfont = pkgs.callPackage ../home/misc/termsynicon.nix {};
in {
  fonts = {
    fontDir.enable = true;
    fontconfig = {
      enable = true;
      allowBitmaps = true;
    };
    packages = [
      myfont
      pkgs.nerd-fonts.departure-mono
      pkgs.cozette
      pkgs.terminus_font
    ];
  };

  console = {
    packages = with pkgs; [
      termsyn
    ];
  };
}
