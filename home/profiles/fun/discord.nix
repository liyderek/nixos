{
  lib,
  config,
  ...
}:
lib.mkIf (config.my.desktopProfile == "fun") {
  xdg.configFile."Vencord/settings/quickCss.css" = {
    force = true;
    text = ''
      @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha-mauve.theme.css");
    '';
  };
}
