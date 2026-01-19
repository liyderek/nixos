-- LSP: Extend LazyVim settings
-- https://github.com/rafi/vim-config

return {
	{
		'neovim/nvim-lspconfig',
		opts = function(_, opts)
			opts = opts or {}
			opts.servers = opts.servers or {}

			-- Your custom LSP keymaps (works with LazyVim)
			opts.keymaps = opts.keymaps or {}
			opts.keymaps = vim.list_extend(opts.keymaps, {
				{ '<leader>cl', false },
				{ '<c-k>', false, mode = 'i' },

				{ '<leader>cli', vim.lsp.buf.incoming_calls, desc = 'Incoming calls' },
				{ '<leader>clo', vim.lsp.buf.outgoing_calls, desc = 'Outgoing calls' },

				{
					'<leader>fwa',
					vim.lsp.buf.add_workspace_folder,
					desc = 'Add Workspace Folder',
				},
				{
					'<leader>fwr',
					vim.lsp.buf.remove_workspace_folder,
					desc = 'Remove Workspace Folder',
				},
				{
					'<leader>fwl',
					function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end,
					desc = 'List Workspace Folders',
				},
			})

			-- clangd fix for NixOS: teach clangd where g++ lives so it finds libstdc++ headers
			opts.servers.clangd = {
				cmd = {
					'clangd',
					'--background-index',
					'--clang-tidy',
					'--query-driver=/nix/store/*-gcc-*/bin/g++,/run/current-system/sw/bin/g++',
				},
				root_dir = function(fname)
					return require('lspconfig.util').root_pattern(
						'compile_commands.json',
						'compile_flags.txt',
						'.git'
					)(fname)
				end,
			}

			return opts
		end,
	},

	{
		'williamboman/mason.nvim',
		enabled = false,
		opts = {
			ui = { border = 'rounded' },
		},
	},
}
