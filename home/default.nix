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
    neovim
    legcord
    cloudflare-warp
    libgcc
    gdb
    lldb
    nil
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
    obs-studio

    emacs-pgtk
    ripgrep
    coreutils
    fd
    clang
  ];

  imports = [
    catppuccin.homeManagerModules.catppuccin
    (import ./hyprland { inherit inputs config pkgs; })
    (import ./cloudflare { inherit config; })
    (import ./waybar { inherit inputs config pkgs; })
    (import ./misc { inherit pkgs config; })
    (import ./scripts { inherit pkgs; })
    (import ./swaync { inherit pkgs; })
  ];

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
