_: {
  flake.modules.nixos.joycond =
    { pkgs, ... }:
    {
      services.joycond = {
        enable = true;
      };

      # Chromium's Gamepad API handles Joy-Cons through raw HID instead of the
      # normal joystick nodes. Grant access to the active local user before
      # systemd's seat-late rule applies the device ACLs.
      services.udev.packages = [
        (pkgs.writeTextDir "lib/udev/rules.d/70-joycon-hidraw.rules" ''
          SUBSYSTEM=="hidraw", KERNEL=="hidraw*", KERNELS=="*:057E:200[67].*", TAG+="uaccess"
        '')
      ];
    };
}
