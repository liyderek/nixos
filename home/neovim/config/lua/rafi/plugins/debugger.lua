local dap = require("dap")
require("dapui").setup()

require("mason-nvim-dap").setup({
	ensure_installed = {},
	automatic_installation = false,
	handlers = {
		function(config)
			require("mason-nvim-dap").default_setup(config)
		end,
		codelldb = function(source_name)
			dap.configurations.cpp = {
				{
					name = "Launch file",
					type = "codelldb",
					request = "launch",
					program = function()
						local path
						vim.ui.input(
							{
								prompt = "Path to executable: ",
								default = vim.fn.getcwd() ..
										"/build/"
							}, function(input)
								path = input
							end)
						vim.cmd [[redraw]]
						return path
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}
		end,
	}
})

return {
	"mfussenegger/nvim-dap",
	"jay-babu/mason-nvim-dap.nvim",
}
