-- Plugins: Colorschemes
-- https://github.com/rafi/vim-config

return {

	-- Use last-used colorscheme
	{
		'rafi/theme-loader.nvim',
		lazy = false,
		priority = 99,
		opts = { initial_colorscheme = 'neohybrid' },
	},

	{ 'rafi/neo-hybrid.vim', priority = 100, lazy = false },
	{ 'rafi/awesome-vim-colorschemes', lazy = false },

	{
		'zenbones-theme/zenbones.nvim',
		-- Optionally install Lush. Allows for more configuration or extending the colorscheme
		-- If you don't want to install lush, make sure to set g:zenbones_compat = 1
		-- In Vim, compat mode is turned on as Lush only works in Neovim.
		dependencies = 'rktjmp/lush.nvim',
		lazy = false,
		priority = 1000,
		-- you can set set configuration options here
		-- config = function()
		--     vim.g.zenbones_darken_comments = 45
		--     vim.cmd.colorscheme('zenbones')
		-- end
	},
}
