return {
	'Civitasv/cmake-tools.nvim',
	lazy = false,
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		require('cmake-tools').setup({
			cmake_compile_commands_options = {
				action = 'lsp',
			},
			configure_args = { '-DCMAKE_EXPORT_COMPILE_COMMANDS=1' },
			on_configure_done = function()
				vim.lsp.stop_client(vim.lsp.get_active_clients())
				vim.cmd('edit') -- reload file to restart LSP with updated flags
			end,
		})
	end,
}
