_: {
  flake.modules.nixos.desktop = { pkgs, ... }: {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = pkgs.stdenv.hostPlatform.isx86_64;
      };

      bluetooth.settings = {
        Policy = {
          ReconnectAttempts = 0;
        };
      };
    };
  };
}
