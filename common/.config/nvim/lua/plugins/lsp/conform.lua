return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	cmd = "ConformInfo",
	keys = {},
	opts = {
		-- Define formatters for each file type
		formatters_by_ft = {
			lua = { "stylua" },
			cpp = { "clang_format" },
			python = { "ruff_format", "ruff_organize_imports" }, -- Ruff en lugar de black
			tex = { "latexindent" },
			sh = { "shfmt" },
			c = { "clang_format" },
			rust = { "rustfmt" },
		},
		default_format_opts = {
			lsp_format = "fallback", -- Fallback to LSP formatting
		},
		-- Wont format if disable by <leader>ct
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return {
				timeout_ms = 500,
				lsp_fallback = true,
			}
		end,
		formatters = {
			shfmt = {
				prepend_args = { "-i", "2" }, -- Custom options for shfmt
			},
		},
	},
	init = function()
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" -- Set Neovim's 'formatexpr' option
	end,
}
