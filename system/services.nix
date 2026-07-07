{
  pkgs,
  lib,
  ...
}: {
  xdg.portal = {
    enable = true;
    # xdg-desktop-portal-wlr is unmaintained and broken with portal 1.18+.
    # xdg-desktop-portal-hyprland is actively maintained, supports the
    # new backend API, and uses wlr-screencopy — which Niri implements.
    # Already installed by programs.hyprland.enable, but listed explicitly.
    extraPortals = [
      # xdg-desktop-portal-hyprland is already added by programs.hyprland.enable
      # Adding it here causes a duplicate .service file conflict
      pkgs.xdg-desktop-portal-gtk
    ];

    config = {
      common.default = ["gtk"];

      niri = {
        # Override the niri module's default (which adds gnome) to just gtk
        default = lib.mkForce ["gtk"];
        "org.freedesktop.impl.portal.ScreenCast" = ["hyprland"];
        "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
        "org.freedesktop.impl.portal.RemoteDesktop" = ["hyprland"];
      };
    };
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
    # desktopManager.plasma6.enable = true;

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
      wireplumber.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    #
    # greetd = {
    #   enable = true;
    #   settings = rec {
    #     initial_session = {
    #       command = "${pkgs.sway}/bin/sway";
    #       user = "derek";
    #     };
    #     default_session = initial_session;
    #   };
    # };

    greetd = {
      enable = true;
      settings = rec {
        # Auto-login derek into niri without password
        initial_session = {
          command = "${pkgs.niri}/bin/niri-session";
          user = "derek";
        };
        default_session = initial_session;
      };
    };
    system76-scheduler.enable = true;

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

  # services.open-webui.enable = true;
}
