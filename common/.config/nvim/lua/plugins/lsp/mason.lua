return {
	{
		"williamboman/mason.nvim",
		lazy = true,
		cmd = { "Mason" },
		config = function()
			require("mason").setup({
				ui = {
					border = "rounded",
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	-- Para conectar mason con lsp
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		cmd = { "LspInstall", "LspUninstall" },
		ft = { "lua", "c", "cpp", "python", "bash", "toml", "typst" },
		config = function()
			require("mason-lspconfig").setup({})
		end,
	},
	-- Ensure installad de mason tool insatller es mejor porque instala cualquier cosa literalmente
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsUpdateSync" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"lua-language-server",
					"clangd",
					"basedpyright",
					"bashls",
					"tinymist",
					"clangd",
					"stylua",
					"ruff",
					"clang-format",
					"shellcheck",
					"shfmt",
					"latexindent",
					"matlab_ls",
				},
				auto_update = false,
				run_on_start = false,
			})
		end,
	},
}
