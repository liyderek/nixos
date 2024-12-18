return {
	'mfussenegger/nvim-dap',
	{
		'jay-babu/mason-nvim-dap.nvim',
		config = function()
			local dap = require('dap')
			require('dapui').setup()

			require('mason-nvim-dap').setup({
				ensure_installed = {},
				automatic_installation = false,
				handlers = {
					function(config)
						require('mason-nvim-dap').default_setup(config)
					end,
					codelldb = function(source_name)
						dap.adapters.lldb = {
							type = 'executable',
							command = '/etc/profiles/per-user/derek/bin/lldb',
							name = 'lldb',
						}
						dap.adapters.codelldb = {
							type = 'server',
							port = '12345',
							executable = {
								command = '/home/derek/.vscode-oss/extensions/vadimcn.vscode-lldb/adapter/codelldb',
								args = { '--port', '12345' },
							},
						}
						dap.configurations.cpp = {
							{
								name = 'Launch file',
								type = 'codelldb',
								request = 'launch',
								program = function()
									local path
									vim.ui.input({
										prompt = 'Path to executable: ',
										default = vim.fn.getcwd() .. '/build/',
									}, function(input)
										path = input
									end)
									vim.cmd([[redraw]])
									return path
								end,
								cwd = '${workspaceFolder}',
								stopOnEntry = false,
							},
						}
					end,
				},
			})
		end,
	},
}
