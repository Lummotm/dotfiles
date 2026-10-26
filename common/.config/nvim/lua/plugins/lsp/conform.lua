-- Conform.nvim: formateo al guardar o a mano

return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	cmd = "ConformInfo",

	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			c = { "clang_format" },
			cpp = { "clang_format" },
			python = { "ruff_format", "ruff_organize_imports" },
			tex = { "latexindent" },
			sh = { "shfmt" },
			rust = { "rustfmt" },
		},

		-- Si no hay formatter de conform, usa el del LSP
		default_format_opts = { lsp_format = "fallback" },

		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return { timeout_ms = 500 }
		end,

		formatters = {
			shfmt = { prepend_args = { "-i", "2" } },
		},
	},

	-- init = function()
	-- 	vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	--
	-- 	-- Nunca formatear C/C++ automáticamente
	-- 	vim.api.nvim_create_autocmd("FileType", {
	-- 		group = vim.api.nvim_create_augroup("no-autoformat-c", { clear = true }),
	-- 		pattern = { "c", "cpp" },
	-- 		callback = function(args)
	-- 			vim.b[args.buf].disable_autoformat = true
	-- 		end,
	-- 	})
	-- end,
}
