{ pkgs, lib, ... }:
{
  boot.binfmt.emulatedSystems = [
    "x86_64-linux"
  ];
  boot.binfmt.registrations.x86_64-linux.interpreter = "${lib.getExe pkgs.box64}";
}
