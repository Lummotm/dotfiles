-- Mason: instala servidores y formatters. Solo bajo demanda (:Mason, :MasonToolsInstall)

return {
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		opts = { ui = { border = "rounded" } },
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
		opts = {
			-- Nombres de paquete de Mason (no los de lspconfig)
			ensure_installed = {
				-- LSP
				"lua-language-server",
				"clangd",
				"basedpyright",
				"bash-language-server",
				"tinymist",
				"matlab-language-server",
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
		},
	},
}
