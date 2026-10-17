# NixOS configurations

One flake, two hosts, and feature-based NixOS/Home Manager modules. The layout
follows the current flake-parts structure of
[thursdaddy/nixos-config](https://github.com/thursdaddy/nixos-config), with Home
Manager integrated into the same module registry.

| Flake host | Architecture | Hardware | Bootloader | System state version |
| --- | --- | --- | --- | --- |
| `nixos` | `x86_64-linux` | AMD desktop | GRUB | `24.11` |
| `nixosmacbook` | `aarch64-linux` | MacBook Pro 13-inch, M1, 2020 | systemd-boot through Asahi U-Boot | `26.11` |

The MacBook's generated hardware settings were read from
`derek@nixosmacbook`, including its actual root and EFI partition UUIDs.
Keep each host's `system.stateVersion` at its original installation value.
Home Manager keeps `24.11` on the desktop and starts at `26.11` on the MacBook.

## Layout

```text
assets/                        Audio, binary package sources, fonts, editor assets
lib/                           Shared package/platform helpers
modules/
  apps/                        Applications and system/user package lists
  base/                        Networking, locale, Nix, users, shells, shared defaults
  containers/                  Podman and virtualisation
  desktop/                     Niri, Sway, Waybar, fonts, input, audio, Apple Silicon
  dev/                         Git, Helix, direnv, tmux, optional editor modules
  hosts/
    nixos/
      config.nix               Hostname, compatibility version, desktop overrides
      imports.nix              Select NixOS and Home Manager feature modules
      nixosSystem.nix          Publish nixosConfigurations.nixos
      hardware-configuration.nix Generated hardware scan, wrapped as a host module
      hardware.nix             Extra NTFS mount and Ethernet tuning
      boot.nix                 Desktop GRUB settings
      packages.nix             Desktop-only system packages
      home.nix                 Host-specific Home Manager settings and state version
      home-packages.nix        Desktop-only user packages
      displays.nix             Monitor/workspace layouts
    nixosmacbook/
      config.nix               MacBook bootloader, Wi-Fi, and laptop settings
      boot.nix                 Quiet U-Boot/systemd-boot and Mocha Plymouth splash
      imports.nix              Select system/user features, including Apple Silicon
      nixosSystem.nix          Publish nixosConfigurations.nixosmacbook
      hardware-configuration.nix MacBook disks and platform
      packages.nix             MacBook-specific system packages
      home.nix                 MacBook Home Manager settings and state version
      displays.nix             Retina display and Touch Bar exclusion
  packages/                    Per-system custom package outputs
  services/                    Auto-update, nix-ld, MongoDB, Sunshine
  flake-parts.nix              Module-registry integration
  home-manager.nix             Attach each host's user configuration to NixOS
  options.nix                  Deferred NixOS/Home Manager host configurations
  overlays.nix                 Shared package overrides
  systems.nix                  Architectures, formatter, development shell
packages/                      Custom package definitions and optional overlays
flake.nix                      Inputs and recursive module discovery
flake.lock                     Pinned versions shared by both hosts
nix.sh                         Host-aware nh wrapper and native-Nix fallback commands
justfile                       Task-runner recipes for nix.sh
```

The MacBook's Asahi vendor firmware is imported into the Nix store as described
below. Nix uses the official NixOS binary cache.

The large audio and ChatGPT binary assets are tracked by Git LFS. Git LFS is
enabled on both hosts and provided by the development shell. After cloning,
download the assets with `git lfs pull` before building. The flake enables LFS
when Nix fetches the repository as well.

### Module composition

`import-tree` discovers the Nix files under `modules/`. Each file registers a
flake module, a named feature, or part of a host configuration:

- `flake.modules.nixos.<feature>` holds system-level settings.
- `flake.modules.homeManager.<feature>` holds user-level settings.
- `configurations.nixos.<hostname>.module` assembles a host's system settings.
- `configurations.homeManager.<hostname>.module` assembles its user settings.

The host's `imports.nix` selects named features for each module class.
`nixosSystem.nix` publishes the finished system configuration; the shared
Home Manager integration selects the matching user configuration by hostname.
Related system and user settings are grouped by feature, such as `desktop/`,
`apps/`, and `dev/`.

Importing a file registers its feature; host imports determine whether it is
active. Optional modules such as `genshin`, `muvm`, `neovim`, and legacy desktop
settings have their own feature names.

### Where to make changes

- Shared settings and dotfiles: the corresponding feature under `modules/`.
- Hostname, disks, bootloader, hardware, or host-specific services:
  `modules/hosts/<hostname>/`.
- Host-specific user settings: `modules/hosts/<hostname>/home.nix`.
- Shared package lists: `modules/apps/{system-packages,home-packages}.nix`.
- Desktop-only packages: `modules/hosts/nixos/{packages,home-packages}.nix`.
- Display layout: `modules/hosts/<hostname>/displays.nix`.
- Custom packages: `packages/`; expose them in `modules/packages/default.nix`.
- Shared overrides: `modules/overlays.nix`.

Track new files with Git so flakes can see them. For example:
`git add modules/hosts/nixosmacbook/new-feature.nix`.

To add a feature that has both system and user settings:

```nix
# modules/dev/tools.nix
_: {
  flake.modules.nixos.tools = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.htop ];
  };
  flake.modules.homeManager.tools = {
    programs.fzf.enable = true;
  };
}
```

Then select `tools` in the corresponding NixOS and Home Manager import lists
in the desired host's `imports.nix`.

## Rebuilding

On the desktop:

```sh
/etc/nixos/nix.sh rebuild nixos
```

On the MacBook, with this checkout available at `/etc/nixos`:

```sh
/etc/nixos/nix.sh rebuild nixosmacbook
```

The shared desktop starts Niri with Noctalia. To activate the `work`
specialisation on either host:

```sh
/etc/nixos/nix.sh work
```

The Nix-related shell aliases all call `nix.sh`:

| Alias | Wrapper command |
| --- | --- |
| `ns` | `rebuild <hostname>` |
| `ns1` | `work <hostname>` |
| `nsu` | `upgrade <hostname>` |
| `nix-flake-update` | `update <hostname>` |
| `nix-clean` | `clean` |
| `cdnix` | `edit` |
| `nvim` | `run --refresh /home/derek/nvf-config#derek-neovim` |

The 2 AM auto-update service also uses the wrapper's `upgrade` command with
its own hostname.

Niri uses its GNOME screen-sharing portal and Waybar's native Niri workspace
module. `Super+F1` opens Niri's hotkey overlay; `Super+Escape` locks the session
with Swaylock.

### Boot splash and virtual consoles

Both hosts use Catppuccin Mocha TTY colors and the 32-pixel Unicode Terminus
console font (`ter-u32n`), including in the initrd. These settings live in
`modules/base/console.nix`.

The MacBook uses the Catppuccin Mocha Plymouth splash with no boot-menu delay,
kernel console messages, or systemd status lines during normal boot.
`modules/hosts/nixosmacbook/boot.nix` also disables Asahi's early console and
builds a silent U-Boot so pre-Linux messages do not interrupt the splash.
Boot diagnostics remain available in the journal after login.

Rebuild each host and reboot to apply its boot and console settings.

### Helper commands

`nix.sh` works from any working directory. Rebuilds, builds, specialisations,
updates, and cleanup use `nh`, including its privilege elevation and build
output. The development shell provides `nh`, `just`, and the formatter:

```sh
nix develop
just rebuild                # Current hostname
just boot                   # Stage a generation for the next reboot
just build nixosmacbook     # Build a host without activating it
just check                  # Evaluate the flake for all supported architectures
just upgrade                # Update inputs, build, and activate
just work                   # Build and activate the work specialisation
just update                 # Update all inputs and build, without activation
just update nixos-apple-silicon
just clean --dry            # Preview cleanup
```

The wrappers perform local builds/rebuilds. Run them on the corresponding
machine, or configure an appropriate ARM builder for the MacBook.

For a kernel or desktop-environment migration, use `./nix.sh boot <hostname>`
and reboot to start the new generation with a fresh graphical session.

`nh` updates inputs as part of a build or switch, so `update` also builds the
selected host. Pass build options after `--` for that command:

```sh
./nix.sh update nixos nixpkgs -- --no-nom
./nix.sh build nixosmacbook --max-jobs 1 --cores 2
```

Flake checks and running arbitrary flake applications use native `nix` because
`nh` has no equivalent commands. `edit` opens the checkout in Codium.

## MacBook / Apple Silicon

The flake imports
[nixos-apple-silicon](https://github.com/nix-community/nixos-apple-silicon)
only for `nixosmacbook`. Its module manages the Asahi kernel, m1n1/U-Boot,
graphics, DSP audio configuration, and speaker protection. The host also uses:

- systemd-boot with `boot.loader.efi.canTouchEfiVariables = false`;
- NetworkManager with the recommended `iwd` Wi-Fi backend;
- `hardware.apple.touchBar` with `tiny-dfr`, media controls, and pixel shifting;
- the existing `hid_apple iso_layout=0` US keyboard fix;
- libinput, Bluetooth/Blueman, UPower, power profiles, a 2x-scaled internal
  display, and no 32-bit graphics/audio;
- its existing enabled firewall.
- zstd-compressed RAM swap with an uncompressed capacity of 100% of RAM,
  an 8 GiB SSD swap file for overflow, and memory-conscious build/download
  concurrency for the 8 GiB MacBook.

### Trackpad motion and scrolling

The MacBook's Niri user service loads the custom curve adapter configured in
`modules/hosts/nixosmacbook/input.nix`. It matches the built-in Apple SPI
trackpad (`05ac:0341`) and uses the same base motion and scroll points generated
from `0.1*x + 0.01*x^2 + 0.005*x^3`: 20 samples, step `0.5`, rounded to three
decimal places like the supplied generator. Libinput interpolates between
samples and extrapolates past the last one. This is a macOS-like cubic curve,
not a measured macOS Tahoe profile.

The adapter's `motionScale = 0.5` in `input.nix` halves pointer speed while
`maxGain = 0.4` caps the base curve's high-speed gain. The final samples form a
constant-gain tail, so fast flicks stay capped even beyond the sampled range.
Low-speed samples below the cap retain their original values. The trackpad's
Niri `scroll-factor` is `0.25` in
`modules/hosts/nixosmacbook/home.nix`, reducing scrolling to one quarter of the
base curve's speed. Pointer and scroll sensitivity are tuned independently of
the gain cap.

`gestureScale = 0.15` configures a separate constant-gain fallback for swipe
gestures. Niri uses libinput's unaccelerated swipe deltas for window/workspace
navigation; leaving the custom profile's fallback at its default raw `1.0`
made those gestures too sensitive. The gesture gain is independent of pointer
and two-finger scrolling, and stays constant even for fast swipes.

After rebuilding, log out and back in to load a changed adapter. Successful
initialisation is logged by `journalctl --user -u niri.service -b`.

### Vendor firmware: first build

Asahi's vendor firmware already exists on the MacBook's EFI partition at
`/boot/vendorfw/firmware.cpio`. Its hash is pinned in
`modules/desktop/apple-silicon.nix` using `pkgs.requireFile`; no firmware
binary needs to be committed or evaluated through an impure `/boot` path.

Before the first build, run **on the MacBook**:

```sh
sudo nix-store --add-fixed sha256 /boot/vendorfw/firmware.cpio
```

Then rebuild with `#nixosmacbook`. The firmware directory is produced in the Nix
store and the upstream Asahi module extracts the firmware normally. If firmware
is missing, the build prints the import command above.

After regenerating the vendor firmware with the Asahi installer, obtain its new
hash, update the pinned hash in the Apple Silicon module, and import it again:

```sh
nix --extra-experimental-features nix-command hash file --type sha256 /boot/vendorfw/firmware.cpio
sudo nix-store --add-fixed sha256 /boot/vendorfw/firmware.cpio
```

Build the MacBook configuration on an ARM Linux machine, or use the MacBook as
an ARM build host. Some theme modules generate files during evaluation, so even
full evaluation on x86 may need access to an ARM Nix store:

```sh
nix eval --store ssh-ng://derek@nixosmacbook --raw \
  .#nixosConfigurations.nixosmacbook.config.system.build.toplevel.drvPath
```

### Architecture-specific packages

Shared package lists use `lib.meta.availableOn` against the host platform.
Unsupported candidates are omitted rather than enabling `allowUnsupportedSystem`.
At the current lock, the shared user list omits MongoDB Compass, Slack, Arduino
IDE, and Vinegar on ARM. Application modules for Discord, Spotify/Spicetify, and
MongoDB Compass also check platform support.

Desktop-only packages include Steam, Lutris, Wine/Winetricks, Gamescope,
AppImage tools, Lunar/Badlion, Android Studio, Omnissa Horizon, Parsec, AMD AMF,
ROCm Ollama, VMware, and the amd64 iLoader package. The MacBook uses CPU Ollama.
ChatGPT is installed on both hosts using the matching Debian asset in
`assets/deb/`. MongoDB, Sunshine, the local Nuvio server, the Minion Flatpak,
NTFS mount, and desktop Ethernet tuning are imported only by the desktop.

Inspect the exclusions after updating inputs:

```sh
nix eval --json \
  .#nixosConfigurations.nixosmacbook.config.home-manager.users.derek.my.excludedPackages
```

## Checks and updates

```sh
# Evaluate on each corresponding machine (does not activate a generation).
nix eval --raw .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.nixosmacbook.config.system.build.toplevel.drvPath

# Format specific files.
nix fmt -- flake.nix modules/hosts/nixosmacbook/config.nix

# Validate flake outputs without building or activating a system.
./nix.sh check

# Update all inputs, or just the Asahi support module.
./nix.sh update
./nix.sh update "$(hostname)" nixos-apple-silicon
```

To add another computer, create `modules/hosts/<hostname>/` with `config.nix`,
`imports.nix`, `home.nix`, a wrapped hardware scan, and `nixosSystem.nix`.
Use its hostname for both deferred configurations and set the architecture in
`nixosSystem.nix`. Recursive module discovery picks up the new host automatically.
