_: {
  configurations.nixos.nixos.module =
    { config, pkgs, ... }:
    let
      storeRoot = "/var/lib/nix-cross-builder";
      image = "/run/media/derek/51D00F980942B197/nix-cross-builder/store.ext4";
      utilLinux = pkgs.lib.getBin pkgs.util-linux;
    in
    {
      systemd.tmpfiles.rules = [ "d ${storeRoot} 0755 root root -" ];

      # Tailscale SSH invokes this as the existing trusted desktop user. Run
      # the isolated local store as root so Nix can create its build sandboxes.
      environment.etc."nix/native-cross-daemon".source = pkgs.writeShellScript "native-cross-daemon" ''
        set -euo pipefail
        if [ "$(${pkgs.coreutils}/bin/id -u)" != 0 ]; then
          exec /run/wrappers/bin/sudo -n "$0" "$@"
        fi

        {
          ${utilLinux}/bin/flock 9
          if ! ${utilLinux}/bin/mountpoint -q ${storeRoot}; then
            ${pkgs.coreutils}/bin/mkdir -p ${storeRoot}
            ${utilLinux}/bin/mount -o loop,nodev,nosuid ${image} ${storeRoot}
          fi
          # Avoid double page-cache buffering for the NTFS/FUSE backing file.
          loopDevice="$(${utilLinux}/bin/findmnt -n -o SOURCE --mountpoint ${storeRoot})"
          ${utilLinux}/bin/losetup --direct-io=on "$loopDevice"
        } 9>/run/lock/nix-cross-builder.mount.lock

        ${pkgs.coreutils}/bin/mkdir -p ${storeRoot}/builds
        if [ "''${1:-}" = --build ]; then
          shift
          exec ${config.nix.package}/bin/nix build \
            --store 'local?root=${storeRoot}' --eval-store daemon \
            --option build-dir ${storeRoot}/builds \
            --option extra-substituters 'daemon?trusted=true' \
            --option http2 false \
            --max-jobs 2 --cores 4 \
            --out-link ${storeRoot}/result-nixosmacbook --print-out-paths "$@"
        fi

        exec ${config.nix.package}/bin/nix-daemon \
          --store 'local?root=${storeRoot}' \
          --option build-dir ${storeRoot}/builds \
          --option extra-substituters 'daemon?trusted=true' \
          --option http2 false \
          --option max-jobs 2 --option cores 4 "$@"
      '';
    };
}
