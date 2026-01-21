{
  lib,
  inputs,
  config,
  pkgs,
  catppuccin,
  ...
}:
let
  pkgsMaster = import inputs.nixpkgs-master {
    system = pkgs.stdenv.hostPlatform.system;
    inherit (pkgs) config;
    overlays = pkgs.overlays or [ ];
  };
  pkgsStable = import inputs.nixpkgs-stable {
    system = pkgs.stdenv.hostPlatform.system;
    inherit (pkgs) config;
    overlays = pkgs.overlays or [ ];
  };
in
{
  home = {
    username = "derek";
    homeDirectory = "/home/derek";

    packages = with pkgs; [
      firefox
      libgcc
      gdb
      lldb
      nixfmt
      fzf
      pfetch
      pamixer
      wl-clipboard
      cliphist
      dconf-editor
      blueman
      irssi
      nix-init
      # jetbrains.clion
      renderdoc
      nix-du
      graphviz
      distrobox
      llvmPackages_19.clang-tools
      python3
      python3Packages.pynput
      nodejs
      nixd
      lazygit
      gnumake
      pkg-config
      ninja
      inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-mono-nerd
      pkgsMaster.aseprite
      alejandra
      lunar-client
      jetbrains.pycharm
      steam
      lutris
      wineWowPackages.waylandFull
      winetricks
      prismlauncher
      i3blocks
      zoom-us
      neovide
      redis
      obs-studio
      libnotify
      mongodb-compass
      texliveFull
      appimage-run
      mupdf
      qbittorrent
      gamescope
      adwsteamgtk
      mailspring
      google-chrome
      ollama-rocm
      cemu
      alacritty
      badlion-client
      tgpt
      runelite
      bolt-launcher
      zulu
      jetbrains.idea
      moonlight-qt
      slack
      jetbrains.clion
      fontforge
      networkmanager_dmenu
      bemenu
      android-studio
      winboat
      arduino-ide
      arduino-cli
      platformio-core
      mangohud
      pkgsStable.stremio
      direnv
      nix-direnv
      inputs.neovim-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
      zed-editor
    ];

    sessionVariables.NIXOS_OZONE_WL = "1";

    stateVersion = "24.11";
  };

  imports = [
    catppuccin.homeModules.catppuccin
    (import ./hyprland { inherit inputs config pkgs; })
    # (import ./cloudflare { inherit config; })
    (import ./waybar { inherit inputs config pkgs; })
    (import ./misc { inherit pkgs config inputs; })
    (import ./scripts { inherit pkgs; })
    (import ./swaync { inherit pkgs; })
    # (import ./neovim { inherit pkgs inputs lib; })
    (import ./sway { inherit lib pkgs; })
  ];

  programs.home-manager.enable = true;
}
