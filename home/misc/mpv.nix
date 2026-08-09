{pkgs, ...}: {
  programs.mpv = {
    enable = true;

    # 1. This explicitly injects uosc into the wrapped mpv binary's environment
    scripts = with pkgs.mpvScripts; [
      uosc
    ];

    # 2. Configure mpv behavior and hide the default UI layers
    config = {
      osc = "no"; # CRITICAL: Disables stock UI so uosc works instead
      osd-bar = "no"; # Disables the default blocky volume/seek bar
      border = "no"; # Optional: Cleaner borderless window look

      # Subtitle and global OSD matching Tomorrow Night
      osd-font = "Maple Mono";
      sub-font = "Maple Mono";
      osd-font-size = 28;
      sub-font-size = 32;
      osd-color = "#c5c8c6";
      osd-back-color = "#1d1f21";
      sub-color = "#c5c8c6";
      sub-border-color = "#1d1f21";
    };

    # 3. Configure uosc theme rules natively inside the module
    scriptOpts = {
      uosc = {
        font = "Maple Mono";
        font_scale = "0.8"; # Makes the uosc UI text elements smaller

        # Tomorrow Night hex mapping (comma separated, values can be standard RRGGBB)
        color = "foreground=c5c8c6,background=1d1f21,accent=81a2be,text=c5c8c6,text_bg=1d1f21";
      };
    };
  };
}
