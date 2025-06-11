return {
	'Civitasv/cmake-tools.nvim',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		require('cmake-tools').setup({
			cmake_compile_commands_options = {
				action = 'lsp',
			},
		})
	end,
}
