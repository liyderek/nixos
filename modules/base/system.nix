_: {
  flake.modules.nixos.base = {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "kernel.perf_event_paranoid" = 2;
      "kernel.kptr_restrict" = 0;
    };

    systemd.user.services.xdg-desktop-portal-wlr.environment = {
      WAYLAND_DISPLAY = "wayland-1";
      XDG_CURRENT_DESKTOP = "sway";
    };
  };
}
