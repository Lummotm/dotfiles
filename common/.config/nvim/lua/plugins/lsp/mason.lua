-- Mason: Package manager for LSP servers, linters, and debuggers
return {
	{
		"williamboman/mason.nvim",
		lazy = true,
		cmd = { "Mason" },
		config = function()
			require("mason").setup({
				ui = { border = "rounded" },
			})
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		cmd = { "LspInstall", "LspUninstall" },
		config = function()
			require("mason-lspconfig").setup({})
		end,
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsUpdateSync" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					-- LSP servers
					"lua-language-server",
					"clangd",
					"basedpyright",
					"bash-language-server",
					"tinymist",
					"matlab_ls",
					"rust-analyzer",
					"texlab",
					-- Formatters y linters
					"stylua",
					"ruff",
					"clang-format",
					"shellcheck",
					"shfmt",
					"latexindent",
				},
				auto_update = false,
				run_on_start = false,
			})
		end,
	},
}
