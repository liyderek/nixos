_: {
  configurations.nixos.nixosmacbook.module =
    { pkgs, ... }:
    let
      trackpadCurve = pkgs.callPackage ../../../packages/libinput-macos-trackpad.nix {
        motionScale = 0.5;
        maxGain = 0.4;
        gestureScale = 0.15;
      };
    in
    {
      systemd.user.services.niri = {
        overrideStrategy = "asDropin";
        environment.LD_PRELOAD = "${trackpadCurve}/lib/libinput-macos-trackpad.so";
      };
    };
}
