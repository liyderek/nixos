return {
	'Civitasv/cmake-tools.nvim',
	lazy = true,
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
		vim.keymap.set(
			'n',
			'<Space>ch',
			':CMakeDebug<CR>',
			{ noremap = true, silent = true }
		)
	end,
	init = function()
		local loaded = false
		local function check_cmake()
			local cwd = vim.uv.cwd()
			if vim.fn.filereadable(cwd .. '/CMakeLists.txt') == 1 then
				require('lazy').load({ plugins = { 'cmake-tools.nvim' } })
				loaded = true
			end
		end
		check_cmake()
		vim.api.nvim_create_autocmd('DirChanged', {
			callback = function()
				if not loaded then
					check_cmake()
				end
			end,
		})
	end,
}
