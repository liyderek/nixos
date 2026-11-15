_: {
  configurations.nixos.nixosmacbook.module =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      stockKernel = pkgs.linux-asahi.kernel;
      fairydustKernel = import ../../../packages/linux-asahi-fairydust.nix {
        inherit lib;
        inherit (pkgs) buildLinux fetchFromGitHub fetchurl;
        baseKernel = stockKernel;
      };
    in
    {
      specialisation.fairydust.configuration = {
        system.nixos.tags = [ "fairydust" ];
        boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor fairydustKernel);
        boot.kernelModules = [
          "phy-apple-atc"
          "phy-apple-dptx"
          "mux-apple-display-crossbar"
          "typec"
          "typec_displayport"
          "tps6598x"
        ];
      };

      # The test kernel must be selectable despite the usual silent boot.
      boot.loader.timeout = lib.mkForce 5;

      # Entry filenames include generation-specific hashes. Resolve the entry
      # after every installation instead of depending on EFI variables.
      boot.loader.systemd-boot.extraInstallCommands = lib.mkIf (!config.isSpecialisation) ''
        ${pkgs.python3}/bin/python3 ${./set-fairydust-default.py} \
          ${lib.escapeShellArg "${config.boot.loader.efi.efiSysMountPoint}/loader"} \
          ${config.specialisation.fairydust.configuration.system.build.toplevel}/init
      '';

      # m1n1 loads DTBs before systemd-boot chooses a kernel. Install the
      # Fairydust payload globally so selecting the test entry gets its DP
      # nodes; retain a stock payload for restoring the original device tree.
      # Child specialisations still build their own payload normally.
      boot.loader.systemd-boot.extraFiles = lib.mkIf (!config.isSpecialisation) {
        "m1n1/boot.bin" = lib.mkForce config.specialisation.fairydust.configuration.system.build.m1n1;
        "m1n1/boot-stock.bin" = config.system.build.m1n1;
      };
    };
}
