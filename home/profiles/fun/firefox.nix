{
  lib,
  config,
  ...
}:
lib.mkIf (config.my.desktopProfile == "fun") {
  programs.firefox = {
    enable = true;

    policies = {
      ExtensionSettings = {
        "{8446b178-c865-4f5c-8ccc-1d7887811ae3}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin-mocha-lavender-git/latest.xpi";
        };
      };
    };

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      path = "iei1hatz.default";
      settings = {
        "extensions.activeThemeID" = "{8446b178-c865-4f5c-8ccc-1d7887811ae3}";
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
      };
      userChrome = ''
        :root {
          --toolbar-bgcolor: #1e1e2e !important;
          --toolbar-color: #cdd6f4 !important;
          --lwt-accent-color: #1e1e2e !important;
          --lwt-text-color: #cdd6f4 !important;
          --tab-selected-bgcolor: #313244 !important;
        }
      '';
    };
  };
}
