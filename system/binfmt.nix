{ pkgs, lib, ... }:
let
  box64-asahi = pkgs.box64.overrideAttrs (old: {
    doCheck = false;
    doInstallCheck = false;
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-D M1=1" ];
  });
in
{
  boot.binfmt.emulatedSystems = [
    "x86_64-linux"
  ];
  boot.binfmt.registrations.x86_64-linux.interpreter = "${lib.getExe pkgs.box64}";

  environment.systemPackages = [ box64-asahi ];
}
