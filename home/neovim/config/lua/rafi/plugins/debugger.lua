local dap = require("dap")
require("dapui").setup()

require("mason-nvim-dap").setup({
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
        vim.ui.input({ prompt = "Path to executable: ", default = vim.loop.cwd() .. "/build/" }, function(input)
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


