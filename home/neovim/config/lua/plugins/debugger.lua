local dap = require('dap')
require('dapui').setup()

local allowed_projects = {
	'/home/derek/Documents/codeforces/',
}

local cwd = vim.fn.getcwd()
local is_allowed = vim.tbl_contains(allowed_projects, cwd)

-- dap.adapters.lldb = {
-- 	type = 'executable',
-- 	command = '/etc/profiles/per-user/derek/bin/lldb',
-- 	name = 'lldb',
-- 	host = '127.0.0.1',
-- 	port = 12345,
-- }
if is_allowed then
	dap.adapters.codelldb = function(cb, config)
		local command = {
			'/run/current-system/sw/bin/g++',
			'-g',
			vim.fn.expand('%'),
			'-o',
			vim.fn.getcwd() .. '/main',
			'-D',
			'DEBUG',
		}
		local output = vim.system(command):wait()
		print('stdout: ' .. output.stdout)
		print('stderr: ' .. output.stderr)

		cb({
			type = 'server',
			port = '12345',
			executable = {
				command = '/home/derek/.vscode-oss/extensions/vadimcn.vscode-lldb/adapter/codelldb',
				args = { '--port', '12345' },
			},
		})
	end
	dap.configurations.cpp = {
		{
			name = 'Launch file',
			type = 'codelldb',
			request = 'launch',
			program = function()
				return vim.fn.getcwd() .. '/main'
			end,
			cwd = '${workspaceFolder}',
			stopOnEntry = false,
		},
	}
end

return {
	{
		'mfussenegger/nvim-dap',
		config = function() end,
	},
}
