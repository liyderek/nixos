# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  myfont = pkgs.callPackage ./home/misc/termsynicon.nix { };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import ./system { inherit pkgs; })
    ./cachix.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      grub = {
        enable = true;
        useOSProber = true;
        copyKernels = true;
        efiSupport = true;
        fsIdentifier = "label";
        devices = [ "nodev" ];
        gfxmodeEfi = "2560x1600";
        # font = lib.mkForce "${pkgs.nerdfonts}/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFont-Regular.ttf";
        fontSize = 72;
        extraEntries = ''
          menuentry "Reboot" {
              reboot
          }
          menuentry "Poweroff" {
              halt
          }
        '';
        # catppuccin.enable = true;
        extraConfig = ''
          GRUB_TIMEOUT_STYLE=hidden
        '';
      };
      timeout = 3;
    };
    plymouth = {
      enable = false;
      theme = "rings";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
      extraConfig = ''
        ShowDelay=0
      '';
    };

    # Enable "Silent Boot"
    consoleLogLevel = 3;
    initrd = {
      verbose = false;
      # systemd.enable = true;
    };
    kernelParams = [
      "quiet"
      "loglevel=3"
      "udev.log-priority=3"
      "splash"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    # loader.timeout = 0;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # unfree
  nixpkgs.config.allowUnfree = true;

  # flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Enable sound with pipewire.
    pulseaudio.enable = false;

    bluetooth.settings = {
      Policy = {
        ReconnectAttempts = 0;
      };
    };
  };
  programs = {
    # hyprland
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };

    zsh.enable = true;

    # nix ld
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        libjpeg
        libjpeg8
        libpng
        fontconfig
        freetype
        libxml2
        glib
        glibc
        libz
      ];
    };

    virt-manager.enable = true;
  };
  networking = {
    hostName = "nixos";

    # network
    networkmanager.enable = true;
    nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];

    firewall = {
      enable = false;
      allowedTCPPorts = [
        47984
        47989
        47990
        48010
      ];
      allowedUDPPortRanges = [
        {
          from = 47998;
          to = 48000;
        }
        #{ from = 8000; to = 8010; }
      ];
    };
  }; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services = {
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    xserver = {
      enable = true;
      windowManager.i3.enable = true;
      # displayManager.gdm.enable = true;
    };

    # Enable the KDE Plasma Desktop Environment.
    # services.displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    xserver.xkb = {
      layout = "us";
      variant = "";
    };
    printing = {
      enable = true;
      browsing = true;
      browsedConf = ''
        BrowseDNSSDSubTypes _cups,_print
        BrowseLocalProtocols all
        BrowseRemoteProtocols all
        CreateIPPPrinterQueues All

        BrowseProtocols all
      '';
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    #
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.sway}/bin/sway";
          user = "derek";
        };
        default_session = initial_session;
      };
    };

    # vpn
    mullvad-vpn.enable = true;
    mullvad-vpn.package = pkgs.mullvad-vpn;

    resolved = {
      enable = true;
      dnssec = "true";
      domains = [ "~." ];
      fallbackDns = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];
      dnsovertls = "true";
    };

    avahi.publish.enable = true;
    avahi.publish.userServices = true;
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;

    xserver.desktopManager.xfce.enable = true;
    xserver.desktopManager.xfce.noDesktop = true;

    # tailscale.enable = true;
    # tailscale.useRoutingFeatures = "server";

    udev.packages = [
      pkgs.platformio-core
      pkgs.openocd
    ];
  };

  security = {
    rtkit.enable = true;

    # set sudo stuff
    sudo.wheelNeedsPassword = false;

    wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
    };
  };

  boot.kernel.sysctl."kernel.perf_event_paranoid" = 2;
  boot.kernel.sysctl."kernel.kptr_restrict" = 0;

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    libvirtd.qemu.swtpm.enable = true;
    vmware.host.enable = true;

    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  users.groups.libvirtd.members = [ "derek" ];

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.derek = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
      "docker"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;
    fontconfig.allowBitmaps = true;
    packages = [
      myfont
    ];
  };

  console = {
    packages = with pkgs; [
      termsyn
    ];
  };

  services.open-webui.enable = true;

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    vim
    libgcc
    cmake
    gcc15
    chromium
    gparted
    ryubing # nintendo
    ripgrep
    ntfs3g
    exfatprogs
    gamemode
    sunshine
    amf
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    perf
    valgrind
    xorg.libxshmfence
    libvirt
    qemu_kvm
    swtpm
    virglrenderer
    vmware-workstation
    cmake-lint
    arion
    bat
    podman
    podman-compose
    nil
    usbmuxd
    (callPackage ./system/iloader/iloader.nix { })
  ];

  system.stateVersion = "24.11"; # dont change
}
