{pkgs, ...}: {
  xdg.configFile."mpv/script-opts/uosc.conf".text = ''
    # Use Maple Mono
    font=Maple Mono
    # Scale down UI elements/fonts to be smaller
    font_scale=0.8

    # Color map: comma separated ARGB hex (AA is alpha transparency)
    # Tomorrow Night Palette mapping
    color=foreground=c5c8c6,background=1d1f21,accent=81a2be,text=c5c8c6,text_bg=1d1f21
  '';
}
