return {
	{
		'jakemason/ouroboros.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		ft = { 'c', 'cpp', 'h', 'hpp' },
		config = function()
			require('ouroboros').setup({
				extension_preferences_table = {
					c = { h = 2, hpp = 1 },
					cpp = { hpp = 2, h = 1 },
					h = { cpp = 2, c = 1 },
					hpp = { cpp = 2, c = 1 },
				},
				switch_to_open_pane_if_possible = true,
			})

			-- Keymaps to open in splits
			vim.api.nvim_create_autocmd('FileType', {
				pattern = { 'c', 'cpp', 'h', 'hpp' },
				callback = function()
					local opts = { buffer = true, silent = true }
					vim.keymap.set('n', '<F9>', ':vsplit | Ouroboros<CR>', opts)
					vim.keymap.set('n', '<F10>', ':Ouroboros<CR>', opts)
				end,
			})
		end,
	},
}
