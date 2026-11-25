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
      boot.nix                 Quiet U-Boot/systemd-boot and minimal Mocha splash
      display-manager.nix      SilentSDDM greeter and MacBook wallpaper
      brightness.nix           Asahi ambient-light sensor and Wluma auto-brightness
      power.nix                AC-connect wake and closed-lid external-display use
      touchbar.nix             tiny-dfr stop/start around suspend/resume
      imports.nix              Select system/user features, including Apple Silicon
      nixosSystem.nix          Publish nixosConfigurations.nixosmacbook
      hardware-configuration.nix MacBook disks and platform
      packages.nix             MacBook-specific system packages
      home.nix                 MacBook Home Manager settings and state version
      displays.nix             Retina display and Touch Bar exclusion
  packages/                    Per-system custom package outputs
  services/                    nix-ld, MongoDB, Sunshine
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

Niri uses its GNOME screen-sharing portal and Waybar's native Niri workspace
module. `Super+F1` opens Niri's hotkey overlay; `Super+Escape` locks the session
with Swaylock.

### Graphical display settings

Run `nwg-displays` to adjust Niri monitor layout, scaling, resolution, and
rotation. The main Niri config includes the writable
`~/.config/niri/monitor.kdl`; GUI changes apply immediately and survive rebuilds.
Home Manager creates that file only when it does not already exist, using the
host's `my.displays.niriMonitorDefaults`. Workspace assignments and the MacBook's
Touch Bar exclusion remain in the declarative host configuration.

On the MacBook, connecting AC power requests a system wake and turns Niri's
monitors back on. `packages/macsmc-ac-wake/` bridges the SMC power-supply
notification to an s2idle wake event; it is built for the kernel selected by each
specialisation. `modules/hosts/nixosmacbook/power.nix` keeps that wake source
enabled and also turns monitors on after a resume while plugged in. Closing the
lid on AC power or while docked leaves the external display usable; an undocked
lid close on battery still suspends. The session remains locked if it was locked
before sleep. Waking from a complete shutdown is a separate firmware feature.

### PDF reading and text-to-speech

Both hosts install Okular with Qt TextToSpeech support and explicitly enable
the socket-activated Speech Dispatcher service in `modules/apps/okular.nix`.
Piper's **Lessac High** US-English neural voice is the default. Its model and
configuration are pinned in the Nix store, so synthesis works offline after
installation. The inference-only Piper package omits training dependencies;
speech rate and volume controls are supported. The stock synthesizers remain
available for selecting other voices or languages.
In Okular, use **Tools → Speak Whole Document** or **Speak Current Page**, or
select text and choose **Speak Text** from its context menu.

After rebuilding, restart `speech-dispatcher.service` in your user session and
reopen Okular to refresh its voice list. Test the new default with
`spd-say -w "This is the Piper neural voice."`.

### Desktop memory and swap

The `nixos` desktop is tuned for 32 GiB of RAM with its existing 32 GiB
`/swapfile` as disk-backed overflow. `modules/hosts/nixos/config.nix` enables
zstd-compressed zram with a logical capacity of 50% of RAM (about 16 GiB) and
swap priority `100`, so the kernel uses it before disk swap. This capacity is
the uncompressed data limit, not preallocated RAM; actual memory use grows
with the compressed pages stored.

`vm.swappiness = 100` balances anonymous-page swapping against file-cache
reclaim, while `vm.page-cluster = 0` disables swap read-ahead for low-latency
zram access. The disk swap file remains available when zram fills up.

After rebuilding, inspect the active devices with `swapon --show` and zram
compression/memory usage with `zramctl`.

### Boot splash and virtual consoles

Both hosts use Catppuccin Mocha TTY colors and the 32-pixel Unicode Terminus
console font (`ter-u32n`), including in the initrd. These settings live in
`modules/base/console.nix`.

The MacBook uses a minimal Plymouth splash: a monochrome NixOS logo above a
thin progress bar on a solid Catppuccin Mocha background. The theme is packaged
in `packages/plymouth-nixos-mocha.nix` and suppresses normal boot messages,
spinners, and percentage labels.

`modules/hosts/nixosmacbook/boot.nix` hides boot-menu delays, disables Asahi's
early console, removes U-Boot's logo/board information, and patches its banner
and file-console output paths to respect silent mode. Initrd activation and
display-manager output go to the journal. Plymouth retains its final frame
while the greeter takes over, rather than restoring the text console. Boot
diagnostics remain available in the journal after login.

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

### Login screen and automatic brightness

The MacBook uses SilentSDDM's `default` preset with
`assets/wallpaper/kurzgesagt-galaxies.webp` on its lock and login views. The
greeter runs under Weston on the main display's persistent DRM alias, leaving
the separate Touch Bar display to tiny-dfr. Both Weston and the Qt greeter use
the macOS cursor theme/package from Niri's Home Manager pointer settings, with
an explicit cursor search path and a `default` alias for Qt/Wayland's fallback
lookups in the minimal greeter environment. Greeter
scaling and cursor size are configured in `display-manager.nix`. Niri is the
default session, with automatic login disabled. The desktop continues to use greetd.

Wluma starts with the MacBook's graphical session and reads the Asahi
`aop-sensors-als` IIO ambient-light sensor. It controls only
`/sys/class/backlight/apple-panel-bl`, without screen capture. Untrained lighting
profiles start at 20/35/50/70/85/100% brightness from night through outdoors;
existing learned profiles are preserved. Adjust brightness manually to teach
Wluma your preferences in each lighting condition. Its logs are available with
`journalctl --user -u wluma.service -b`.

Noctalia's MacBook-only brightness override maps `eDP-1` explicitly to
`apple-panel-bl`. This also routes the Touch Bar's screen-brightness buttons to
the main screen: automatic device detection otherwise prefers the Touch Bar's
separate raw backlight.

### Experimental USB-C display output

The MacBook has a `fairydust` boot-menu specialisation for testing native USB-C
DisplayPort Alt Mode, including USB-C-to-HDMI adapters. It pins Asahi's Fairydust
commit `ce9f2eba72c061a50b2d790450e90af3439d8c24`, retains the two subsequent
stock-kernel fixes, and identifies itself as `7.1.13-fairydust` in `uname -r`.
Debug information is zlib-compressed to limit kernel build disk usage.
Fairydust is selected as the default after every bootloader installation; the
normal `NixOS` entry provides the stock Asahi kernel.

Asahi's stage-2 m1n1 loads its device tree **before** the boot menu. Therefore
both kernel entries share the Fairydust device-tree payload at
`/boot/m1n1/boot.bin`; the stock payload is also installed as
`/boot/m1n1/boot-stock.bin`. This is not a fully isolated device-tree experiment.
To restore the stock device tree from a working Linux session, run
`sudo install -m644 /boot/m1n1/boot-stock.bin /boot/m1n1/boot.bin` and choose the
normal kernel entry on the next boot.

After rebuilding for boot, reboot; `NixOS (fairydust)` is selected by default in
the five-second boot menu. When this menu is enabled, U-Boot's EFI hand-off
re-enables console output so the menu is visible. Connect the adapter to
**USB-C Left-front**, the left-side port closer to the trackpad. Starting with
the display connected may work better than hot-plugging. Check `uname -r` and
`niri msg outputs`, then use
`nwg-displays` to arrange the screen. Actual display output still needs a
hardware test; Fairydust remains experimental and can have hot-plug, resume,
colour, and display-mode quirks.

### Touch Bar resume recovery

The MacBook stops `tiny-dfr.service` synchronously before suspend, releasing its
DRM/input devices before the kernel powers down the Touch Bar, then queues a
fresh start after resume. Stopping has a five-second timeout; startup failures
retry every five seconds while the devices become ready. A post-resume restart
alone cannot prevent the observed DRM commit timeouts. If the driver is already
stuck from an earlier sleep, reboot after applying the configuration, then check
`journalctl -u tiny-dfr.service -u sleep-actions.service -b` after a sleep/wake
cycle. The new suspend sequence still needs hardware sleep/wake verification.

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
ROCm Ollama, VMware, and the amd64 iLoader package. ChatGPT is shared by both
hosts and uses the pinned `nixpkgs-master` package, which includes Linux support
from [nixpkgs PR #551713](https://github.com/NixOS/nixpkgs/pull/551713).
The MacBook uses CPU Ollama. MongoDB, Sunshine, the local Nuvio server, the
Minion Flatpak, NTFS mount, and desktop Ethernet tuning are imported only by the
desktop.

Inspect the exclusions after updating inputs:

```sh
nix eval --json \
  .#nixosConfigurations.nixosmacbook.config.home-manager.users.derek.my.excludedPackages
```

## OpenClaw

`modules/apps/openclaw.nix` configures OpenClaw through the first-party
`nix-openclaw` Home Manager module. It installs the CLI and starts the local
gateway at login, including its browser dashboard at <http://127.0.0.1:18789>.
The gateway token is generated locally during activation.

OpenClaw also manages a private Tailscale Serve HTTPS route while the gateway
runs. On the desktop, open <https://nixos.tail6e150d.ts.net/> from a device on
your tailnet; the MacBook uses <https://nixosmacbook.tail6e150d.ts.net/> after
rebuilding there. Tailscale identity authenticates browser connections, while
the local gateway retains token authentication. The NixOS configuration grants
`derek` Tailscale operator access so the user service can manage its Serve route.

The agent uses `openai/gpt-6-sol`, high reasoning effort, the OpenClaw runtime,
and local tools. Its identity and instructions are Nix-managed in
`~/.openclaw/workspace`; project files elsewhere in your home directory are
accessible using their absolute paths. Runtime credentials and sessions are
stored under `~/.openclaw/` on each machine.

Sign in to your ChatGPT subscription on each host:

```sh
openclaw models auth login --provider openai
```

Run `openclaw tui` for the terminal UI or `openclaw dashboard` for the browser
interface. Inspect the gateway with `systemctl --user status openclaw-gateway`.
Change managed settings in `modules/apps/openclaw.nix` and rebuild the host.

### OpenClaw integrations

`modules/apps/openclaw-integrations.nix` configures GitHub through `gh`, Google
Workspace through `gog`, a visible agent-only Chromium profile, the Obsidian
vault at `~/Documents/Obsidian Vault`, and Brave web search. The desktop also
runs the Discord bot; keeping it on one gateway avoids duplicate bot replies
from both hosts. DMs and commands are restricted to Derek's Discord account.

Install [claw to your Discord account](https://discord.com/oauth2/authorize?client_id=1566203251257245696&integration_type=1&scope=applications.commands)
with **Add to My Apps**, then use `/jarvis` and fill its `input` option. The command
works in server channels, DMs, and group DMs where Discord permits user-installed
apps, with replies visible to everyone in the conversation. A pinned Nix patch to
the Discord plugin admits only this command when the sender explicitly matches
the command, owner, and DM
allowlists. Other server/group-DM messages remain disabled. The plugin's build
checks exercise native command authorization for each context and rejected users.

Runtime secret files live in `~/.config/openclaw/secrets/`: `discord-bot-token`
on the desktop, `brave-api-key`, `google-oauth-client.json`, and the locally
generated `google-keyring-password`. GitHub and Google OAuth sessions remain
in their tools' user-owned credential stores.

Authorize accounts on each host with:

```sh
gh auth login --hostname github.com --git-protocol https --web
gog auth credentials ~/.config/openclaw/secrets/google-oauth-client.json
gog auth add derekli21870@gmail.com --services gmail,calendar,drive,docs,sheets
```

The `gog` wrapper supplies the account and local file-keyring password to both
interactive commands and the gateway. To use Obsidian's official CLI, enable
Settings → General → Command line interface in Obsidian and keep its app running;
direct Markdown access to the vault also works.

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
