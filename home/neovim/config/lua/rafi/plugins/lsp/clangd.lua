return {
	{
		'neovim/nvim-lspconfig',
		config = function(_, opts)
			-- Setup autoformat
			LazyVim.format.register(LazyVim.lsp.formatter())

			-- Setup keymaps.
			LazyVim.lsp.on_attach(function(client, buffer)
				require('rafi.plugins.lsp.keymaps').on_attach(client, buffer)
			end)


			LazyVim.lsp.setup()
			LazyVim.lsp.on_dynamic_capability(
				require('rafi.plugins.lsp.keymaps').on_attach
			)

			-- Diagnostics signs and highlights.
			if vim.fn.has('nvim-0.10.0') == 0 then
				if type(opts.diagnostics.signs) ~= 'boolean' then
					for severity, icon in pairs(opts.diagnostics.signs.text) do
						local name = vim.diagnostic.severity[severity]
							:lower()
							:gsub('^%l', string.upper)
						name = 'DiagnosticSign' .. name
						vim.fn.sign_define(name, { text = icon, texthl = name, numhl = '' })
					end
				end
			end

			require('lspconfig').clangd.setup{}
		end
	}
}
