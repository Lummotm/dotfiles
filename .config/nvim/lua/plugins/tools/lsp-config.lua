-- LSP o Language Server Protocol es un servicio que permite que el compilador
-- que sabe como va el codigo y todo eso, sea capaz de tener influencia en

return {
	{
		"williamboman/mason.nvim",
		-- mason permite administrar servidores de lenguaje instalarlos etc.
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		-- mason-lspconfig sirve para integrar mason con lsp, es super util por el tag
		-- ensure_installed que permite que se haga de manera automatica la instalación
		-- del servidor de lenguaje y todo eso
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"matlab_ls",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.matlab_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.texlab.setup({
				capabilities = capabilities,
			})
			-- Configuración global de diagnósticos
			vim.diagnostic.config({
				virtual_text = {
					prefix = "● ", -- Puedes cambiar esto por '■', '▎', etc.
					source = "if_many",
					format = function(diagnostic)
						return string.format("%s", diagnostic.message)
					end,
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})
		end,
	},
}
