-- LSP: Extend LazyVim settings
-- https://github.com/rafi/vim-config
--
--
return {
	{
		'neovim/nvim-lspconfig',
		opts = function(_, opts)
			-- Add or modify keymaps (as you already have)
			local keys = require('lazyvim.plugins.lsp.keymaps').get()
			vim.list_extend(keys, {
				{ '<leader>cl', false },
				{ '<c-k>', false, mode = 'i' },
				{ '<leader>cli', vim.lsp.buf.incoming_calls, desc = 'Incoming calls' },
				{ '<leader>clo', vim.lsp.buf.outgoing_calls, desc = 'Outgoing calls' },
				{
					'<leader>fwa',
					vim.lsp.buf.add_workspace_folder,
					desc = 'Show Workspace Folders',
				},
				{
					'<leader>fwr',
					vim.lsp.buf.remove_workspace_folder,
					desc = 'Remove Workspace Folder',
				},
				{
					'<leader>fwl',
					'<cmd>lua =vim.lsp.buf.list_workspace_folders()<CR>',
					desc = 'List Workspace Folders',
				},
			})

			-- ADD lua_ls TO THE SERVERS TABLE
			opts.servers = opts.servers or {}
			opts.servers.lua_ls = {
				settings = {
					Lua = {
						diagnostics = {
							globals = { 'vim' }, -- Recognize the 'vim' global variable
						},
					},
				},
			}
			return opts
		end,
	},
	{
		'mason.nvim',
		opts = {
			ui = { border = 'rounded' },
			ensure_installed = { 'lua-language-server' }, -- ENSURE LSP SERVER IS INSTALLED
		},
	},
}
