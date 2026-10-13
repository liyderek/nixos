_: {
  flake.modules.homeManager.base =
    {
      lib,
      inputs,
      config,
      pkgs,
      catppuccin,
      ...
    }:
    {
      options.my.desktopProfile = lib.mkOption {
        type = lib.types.enum [ "work" ];
        default = "work";
        description = "Selects the Home Manager desktop profile.";
      };

      imports = [
        catppuccin.homeModules.catppuccin
      ];

      config = {
        home = {
          username = "derek";
          homeDirectory = "/home/derek";

          sessionVariables.NIXOS_OZONE_WL = "1";

        };

        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "x-scheme-handler/about" = [ "firefox.desktop" ];
            "x-scheme-handler/unknown" = [ "firefox.desktop" ];
            "text/html" = [ "firefox.desktop" ];
            "application/xhtml+xml" = [ "firefox.desktop" ];

            "inode/directory" = [ "thunar.desktop" ];
            "x-directory/normal" = [ "thunar.desktop" ];

            "application/pdf" = [ "org.pwmt.zathura.desktop" ];
            "application/x-pdf" = [ "org.pwmt.zathura.desktop" ];

            "video/mp4" = [ "mpv.desktop" ];
            "video/x-matroska" = [ "mpv.desktop" ];
            "video/webm" = [ "mpv.desktop" ];
            "video/quicktime" = [ "mpv.desktop" ];
            "video/x-msvideo" = [ "mpv.desktop" ];
            "video/mpeg" = [ "mpv.desktop" ];
          };
        };

        programs.home-manager.enable = true;
      };
    };
}
