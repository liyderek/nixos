{
  lib,
  inputs,
  config,
  pkgs,
  catppuccin,
  ...
}: let
  pkgsMaster = import inputs.nixpkgs-master {
    system = pkgs.stdenv.hostPlatform.system;
    inherit (pkgs) config;
    overlays = pkgs.overlays or [];
  };
  pkgsStable = import inputs.nixpkgs-stable {
    system = pkgs.stdenv.hostPlatform.system;
    inherit (pkgs) config;
    overlays = pkgs.overlays or [];
  };
in {
  options.my.desktopProfile = lib.mkOption {
    type = lib.types.enum [
      "work"
      "fun"
    ];
    default = "work";
    description = "Selects the Home Manager desktop profile.";
  };

  imports = [
    catppuccin.homeModules.catppuccin
    (import ./hyprland {inherit inputs config pkgs;})
    # (import ./cloudflare { inherit config; })
    (import ./waybar {inherit inputs config pkgs;})
    (import ./misc {inherit pkgs config inputs;})
    (import ./scripts {inherit pkgs;})
    (import ./swaync {inherit pkgs;})
    # (import ./neovim { inherit pkgs inputs lib; })
    (import ./sway {inherit lib pkgs;})
    ./profiles/work.nix
    ./profiles/fun.nix
  ];

  config = {
    home = {
      username = "derek";
      homeDirectory = "/home/derek";

      packages = with pkgs;
        lib.optionals (config.my.desktopProfile != "fun") [
          firefox
        ]
        ++ lib.optionals (config.my.desktopProfile == "work") [
          remmina
        ]
        ++ [
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
          aseprite
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
          thunar-archive-plugin
          file-roller
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
          direnv
          nix-direnv
          zed-editor
          github-copilot-cli
          opencode
          stremio-linux-shell
          emacs
          copilot-language-server
          libtool
          ruff
          lld
          mold
          prettier
          waypipe
          mathematica
          jetbrains.rust-rover
          anki
          obsidian
          boilr
          basedpyright
          pandoc
          elan
          jetbrains.datagrip
        ];

      sessionVariables.NIXOS_OZONE_WL = "1";

      stateVersion = "24.11";
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
        "x-scheme-handler/about" = ["firefox.desktop"];
        "x-scheme-handler/unknown" = ["firefox.desktop"];
        "text/html" = ["firefox.desktop"];
        "application/xhtml+xml" = ["firefox.desktop"];

        "inode/directory" = ["thunar.desktop"];
        "x-directory/normal" = ["thunar.desktop"];
      };
    };

    programs.home-manager.enable = true;
  };
}
