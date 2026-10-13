_: {
  flake.modules.homeManager.apps =
    {
      customLib,
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      packages =
        with pkgs;
        [
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
          jetbrains.pycharm
          prismlauncher
          i3blocks
          neovide
          redis
          libnotify
          mongodb-compass
          texliveFull
          mupdf
          qbittorrent
          mailspring
          google-chrome
          cemu
          alacritty
          tgpt
          runelite
          thunar-archive-plugin
          file-roller
          bolt-launcher
          zulu
          jetbrains.idea
          slack
          jetbrains.clion
          fontforge
          networkmanager_dmenu
          bemenu
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
          jetbrains.rust-rover
          anki
          obsidian
          boilr
          basedpyright
          pandoc
          elan
          jetbrains.datagrip
          distroshelf
          antigravity-cli
          calibre
          xwayland-satellite
          zathura
          claude-code
          pawn-appetit
          vinegar
          stockfish
          moonlight-qt
        ]
        ++ lib.optional (inputs.claude-desktop.packages ? ${pkgs.stdenv.hostPlatform.system}) (
          inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop.override {
            nodePackages = { inherit (pkgs) asar; };
          }
        );
      available = lib.meta.availableOn pkgs.stdenv.hostPlatform;
    in
    {
      options.my.excludedPackages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        readOnly = true;
        description = "Shared package candidates omitted because this host's architecture is unsupported.";
      };

      config = {
        my.excludedPackages = map lib.getName (lib.filter (package: !available package) packages);
        home.packages = customLib.supportedPackages pkgs packages ++ [
          pkgs.firefox
          pkgs.remmina
        ];
      };
    };
}
