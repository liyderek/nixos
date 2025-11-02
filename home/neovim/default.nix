{ pkgs, inputs, lib, ... }:
{
  home.packages = with pkgs; [
    luarocks
    lua
    go
    php
    php84Packages.composer
    cargo
    unzip
    fd
    lua-language-server
    stylua
    tree-sitter
  ];

  home.file.".config/nvim" = {
    source = ./config;
    recursive = true;
  };

	programs.neovim = {
		enable = true;
		extraWrapperArgs = let
			nvim-treesitter = pkgs.vimPlugins.nvim-treesitter;
			nvim-treesitter-parsers =
				builtins.map (grammar: nvim-treesitter.grammarToPlugin grammar) nvim-treesitter.allGrammars;
		in [
			"--set"
			"NVIM_TREESITTER_PARSERS"
			(lib.concatStringsSep "," nvim-treesitter-parsers)
		];
	};
}
