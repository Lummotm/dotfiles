return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
		{
			"folke/lazydev.nvim",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
	},

	-- stylua: ignore start
	keys = {
		{ "<leader>d",  vim.diagnostic.open_float,        desc = "Show diagnostic in a floating window" },
		{ "gd",         vim.lsp.buf.definition,           desc = "Go to definition" },
		{ "<leader>ca", vim.lsp.buf.code_action,          desc = "Show code actions" },
	},
	-- stylua: ignore end

	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()
		local lspconfig = require("lspconfig")

		require("lazydev").setup()

		vim.diagnostic.config({
			signs = true,
			underline = true,
			virtual_text = false,
			update_in_insert = false,
			severity_sort = true,
		})

		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
					diagnostics = {
						globals = { "vim" },
						disable = {
							"missing-fields",
							"trailing-space",
							"lowercase-global",
						},
					},
					workspace = {
						checkThirdParty = false,
					},
					telemetry = { enable = false },
				},
			},
		})

		lspconfig.clangd.setup({ capabilities = capabilities })
		lspconfig.pyright.setup({ capabilities = capabilities })
		lspconfig.taplo.setup({ capabilities = capabilities })
	end,
}
