-- Conform.nvim: Code formatter
-- Formats code on save or manual trigger using language-specific formatters

return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	cmd = "ConformInfo",

	opts = {
		-- Formatters per filetype: First available formatter is used
		formatters_by_ft = {
			lua = { "stylua" }, -- Lua configuration
			cpp = { "clang_format" }, -- C++
			c = { "clang_format" }, -- C
			python = { "ruff_format", "ruff_organize_imports" }, -- Python (format + imports)
			tex = { "latexindent" }, -- LaTeX
			sh = { "shfmt" }, -- Shell scripts
			rust = { "rustfmt" }, -- Rust
		},

		-- Fallback to LSP formatting if no conform formatter exists
		default_format_opts = { lsp_format = "fallback" },

		-- Format on save: Respects per-buffer disable flag
		format_on_save = function(bufnr)
			-- Check global and buffer-local disable flags
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return { timeout_ms = 500, lsp_fallback = true }
		end,

		-- Custom formatter options
		formatters = {
			shfmt = { prepend_args = { "-i", "2" } }, -- Indent with 2 spaces
		},
	},

	-- Register conform as the formatter for :format command
	init = function()
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		-- Nunca formatear C/C++ automáticamente (ni conform ni fallback a LSP)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "c", "cpp" },
			callback = function(args)
				vim.b[args.buf].disable_autoformat = true
			end,
		})
	end,
}
