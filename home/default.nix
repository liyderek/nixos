{
  inputs,
  config,
  pkgs,
  catppuccin,
  nix-doom-emacs-unstraightened,
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
  ];

  imports = [
    catppuccin.homeManagerModules.catppuccin
    nix-doom-emacs-unstraightened.hmModule
    (import ./hyprland { inherit inputs config pkgs; })
    (import ./cloudflare { inherit config; })
    (import ./waybar { inherit inputs config pkgs; })
    (import ./misc { inherit pkgs config; })
    (import ./scripts { inherit pkgs; })
    (import ./swaync { inherit pkgs; })
    (import ./emacs { inherit inputs pkgs; })
  ];

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
