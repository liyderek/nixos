_: {
  configurations.nixos.nixosmacbook.module = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      brightnessctl
      widevine-cdm
      asahi-bless
      (callPackage ../../../packages/chatgpt.nix { })
    ];

    # The ARM CDM is adapted using Asahi's widevine-installer fixup.
    nixpkgs.overlays = [
      (_final: prev: {
        chromium = prev.chromium.override { enableWideVine = true; };
        firefox = prev.firefox.override {
          extraPrefs = ''
            pref("media.gmp-widevinecdm.version", "system-installed");
            pref("media.gmp-widevinecdm.visible", true);
            pref("media.gmp-widevinecdm.enabled", true);
            pref("media.gmp-widevinecdm.autoupdate", false);
            pref("media.eme.enabled", true);
            pref("media.eme.encrypted-media-encryption-scheme.enabled", true);
          '';
        };
      })
    ];

    environment.etc = {
      "widevine/gmp-widevinecdm/system-installed/manifest.json".source =
        "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm/manifest.json";
      "widevine/gmp-widevinecdm/system-installed/libwidevinecdm.so".source =
        "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm/_platform_specific/linux_arm64/libwidevinecdm.so";
    };
    environment.sessionVariables.MOZ_GMP_PATH = "/etc/widevine/gmp-widevinecdm/system-installed";
  };
}
