return {
	"lervag/vimtex",
	ft = "tex",
	init = function()
		vim.g.vimtex_syntax_enabled = 0
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_view_method = "zathura"
		vim.g.vimtex_quickfix_ignore_filters = {
			"Underfull",
			"Overfull",
			"specifier changed to",
		}
		vim.g.vimtex_compiler_latexmk = {
			continuous = 1,
			options = {
				"-pdf",
				"-shell-escape",
				"-verbose",
				"-file-line-error",
				"-interaction=nonstopmode",
			},
		}
		vim.g.vimtex_matchparen_enabled = 0
		vim.api.nvim_create_autocmd("VimLeavePre", {
			pattern = "*.tex",
			callback = function()
				vim.cmd("VimtexClean")
			end,
		})
	end,
	keys = {
		{ "<leader>lv", "<cmd>VimtexView<CR>", desc = "View PDF", ft = "tex" },
		{ "<leader>lk", "<cmd>VimtexStop<CR>", desc = "Stop compilation", ft = "tex" },
		{ "<leader>le", "<cmd>VimtexErrors<CR>", desc = "Show errors", ft = "tex" },
		{ "<leader>lo", "<cmd>VimtexCompileOutput<CR>", desc = "Show output", ft = "tex" },
		{ "<leader>lc", "<cmd>VimtexClean<CR>", desc = "Clean aux files", ft = "tex" },
		{ "<leader>lC", "<cmd>VimtexClean!<CR>", desc = "Full clean", ft = "tex" },
		{ "<leader>li", "<cmd>VimtexInfo<CR>", desc = "Project info", ft = "tex" },
		{ "<leader>ls", "<cmd>VimtexToggleMain<CR>", desc = "Toggle main file", ft = "tex" },
		{ "<leader>lr", "<cmd>VimtexReverseSearch<CR>", desc = "Reverse search", ft = "tex" },
		{ "<leader>lx", "<cmd>VimtexReload<CR>", desc = "Reload VimTeX", ft = "tex" },
		{ "<leader>lt", "<cmd>VimtexTocToggle<CR>", desc = "Table of contents", ft = "tex" },
	},
}
