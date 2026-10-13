{ inputs, ... }: {
  flake.modules.nixos.apple-silicon =
    { pkgs, ... }:
    let
      firmware = pkgs.requireFile {
        name = "firmware.cpio";
        hash = "sha256-7X9DZYM6HyehBGjPClp9RQQ5OPVvkATCiwOnNI3Zq1o=";
        message = ''
          Import this MacBook's Asahi vendor firmware before building:
            sudo nix-store --add-fixed sha256 /boot/vendorfw/firmware.cpio
          The firmware hash is pinned in modules/desktop/apple-silicon.nix.
          See README.md for details, including firmware updates.
        '';
      };
    in
    {
      imports = [ inputs.nixos-apple-silicon.nixosModules.default ];
      hardware.asahi = {
        enable = true;
        setupAsahiSound = true;
        peripheralFirmwareDirectory = pkgs.runCommand "nixosmacbook-vendor-firmware" { } ''
          mkdir -p "$out"
          ln -s ${firmware} "$out/firmware.cpio"
        '';
      };

      hardware.apple.touchBar = {
        enable = true;
        package = pkgs.tiny-dfr;
        settings = {
          MediaLayerDefault = true;
          EnablePixelShift = true;
        };
      };

      # This MacBook has a US keyboard; preserve its working layout fix.
      boot.extraModprobeConfig = ''
        options hid_apple iso_layout=0
      '';
    };
}
