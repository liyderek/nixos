_: {
  configurations.homeManager.nixos.module = { pkgs, ... }: {
    home.packages = with pkgs; [
      lunar-client
      steam
      lutris
      wineWowPackages.waylandFull
      winetricks
      appimage-run
      gamescope
      adwsteamgtk
      ollama-rocm
      badlion-client
      android-studio
      omnissa-horizon-client
      parsec-bin
    ];
  };
}
