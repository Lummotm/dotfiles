return {
	-- Core Mason
	{
		"williamboman/mason.nvim",
		event = "BufReadPre",
		build = ":MasonUpdate",
		opts = {
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},

	-- LSP auto-installer
	{
		"williamboman/mason-lspconfig.nvim",
		event = "BufReadPre",
		dependencies = { "mason.nvim" },
		opts = {
			ensure_installed = {
				"lua_ls",
				"clangd",
				"pyright",
				"taplo",
			},
		},
	},

	-- Formatters/linters auto-installer
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		cmd = "Mason",
		dependencies = { "mason.nvim" },
		opts = {
			ensure_installed = {
				"lua-language-server",
				"pyright",
				"clangd",
				"stylua",
				"black",
				"clang-format",
				"shellcheck",
				"shfmt",
				"latexindent",
			},
			auto_update = false,
			run_on_start = false,
		},
	},
}
