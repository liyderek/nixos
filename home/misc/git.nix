{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Derek";
      email = "zedikdagod@gmail.com";
    };
  };
}
