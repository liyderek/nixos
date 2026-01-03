{ pkgs, ... }:
{
  #

  i18n.supportedLocales = [
    "zh_CN.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-rime
        fcitx5-pinyin-zhwiki
        fcitx5-nord
      ];
    };
  };
}
