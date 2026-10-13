{ lib }: {
  supportedPackages =
    pkgs: packages: lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) packages;
}
