{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # discord
    (discord.override {
      withVencord = true;
    })
  ];
  xdg.configFile."Vencord/themes/custom.css".text = ''
    @import url("https://gist.githubusercontent.com/emctague/aab1d43a90174930939ae51c8db09553/raw/7c1ed130bb7d053060019ae0a73d9859bb525613/bd-gruvbox.css");
  '';
}
