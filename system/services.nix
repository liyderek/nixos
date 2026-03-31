{ pkgs, ... }:
{
  xdg.portal.enable = true;

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

    # resolved = {
    # enable = true;
    # settings = {
    # Domains = ["~."];
    # FallbackDNS = [
    # "1.1.1.1#one.one.one.one"
    # "1.0.0.1#one.one.one.one"
    # ];
    # };
    # };

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

    usbmuxd.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    tailscale.enable = true;
  };

  services.open-webui.enable = true;
}
