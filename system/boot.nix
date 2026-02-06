{ pkgs, ... }:
{
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
}
