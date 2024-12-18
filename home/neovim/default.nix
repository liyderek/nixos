{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    neovim
    luarocks
    lua
  ];

  home.file.".config/nvim" = {
    source = ./config;
    recursive = true;
  };
}
