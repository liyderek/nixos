{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    neovim
  ];

  xdg.configFile.nvim.source = ./nvim;
}
