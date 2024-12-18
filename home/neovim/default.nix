{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    neovim
    luarocks
    lua
    go
    php
    php84Packages.composer
    cargo
  ];

  home.file.".config/nvim" = {
    source = ./config;
    recursive = true;
  };
}
