_: {
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      myfont = pkgs.callPackage ../../packages/termsynicon.nix { };
    in
    {
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
    };
}
