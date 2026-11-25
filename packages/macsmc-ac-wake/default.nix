{
  lib,
  stdenv,
  kernel,
}:
stdenv.mkDerivation {
  pname = "macsmc-ac-wake";
  version = "1.0";
  src = ./.;

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

  makeFlags = kernel.makeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)"
  ];
  buildFlags = [ "modules" ];

  installPhase = ''
    runHook preInstall
    install -Dm644 macsmc_ac_wake.ko \
      "$out/lib/modules/${kernel.modDirVersion}/extra/macsmc_ac_wake.ko"
    runHook postInstall
  '';

  meta = {
    description = "Wake Apple Silicon laptops when AC power is connected";
    license = lib.licenses.gpl2Only;
    platforms = [ "aarch64-linux" ];
  };
}
