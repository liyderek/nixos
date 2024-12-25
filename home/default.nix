{
  inputs,
  config,
  pkgs,
  catppuccin,
  ...
}:

{
  home.username = "derek";
  home.homeDirectory = "/home/derek";

  home.packages = with pkgs; [
    firefox
    libgcc
    gdb
    lldb
    nixfmt-rfc-style
    fzf
    pfetch
    pamixer
    wl-clipboard
    cliphist
    dconf-editor
    blueman
    irssi
    nix-init
    jetbrains.clion
    renderdoc
    nix-du
    graphviz
    distrobox
    llvmPackages_19.clang-tools
    python3
    nodejs
    nixd
    lazygit
    gnumake
    pkg-config
    ninja
    python312Packages.spacy
    brave
    inputs.apple-fonts.packages.${pkgs.system}.sf-mono-nerd
    aseprite
    python3Packages.six
    alejandra
    lunar-client
    jetbrains.pycharm-professional
  ];

  imports = [
    catppuccin.homeManagerModules.catppuccin
    (import ./hyprland { inherit inputs config pkgs; })
    # (import ./cloudflare { inherit config; })
    (import ./waybar { inherit inputs config pkgs; })
    (import ./misc { inherit pkgs config inputs; })
    (import ./scripts { inherit pkgs; })
    (import ./swaync { inherit pkgs; })
    (import ./neovim { inherit pkgs inputs; })
  ];

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
