return {
	"lervag/vimtex",
	ft = "tex", -- Load VimTeX only for TeX file types
	init = function()
		-- Global VimTeX settings, applied before plugin fully loads
		vim.g.vimtex_syntax_enabled = 0 -- Disable VimTeX's syntax highlighting (often handled by Tree-sitter)
		vim.g.vimtex_compiler_method = "latexmk" -- Use latexmk for compilation
		vim.g.vimtex_view_method = "zathura" -- Set Zathura as the default PDF viewer
		vim.g.vimtex_quickfix_open_on_warning = 0 -- Stop the focking quickfix on warnings

		-- Ignore common LaTeX compilation warnings in the quickfix list
		vim.g.vimtex_quickfix_ignore_filters = {
			"Underfull",
			"Overfull",
			"specifier changed to",
		}

		-- Configuration for the latexmk compiler
		vim.g.vimtex_compiler_latexmk = {
			continuous = 1, -- Enable continuous compilation (watches for file changes)
			options = {
				"-pdf", -- Output PDF format
				"-shell-escape", -- Allow shell commands (e.g., for external tools)
				"-verbose", -- More verbose output
				"-file-line-error", -- Include file and line numbers in errors
				"-interaction=nonstopmode", -- Don't pause on errors
			},
		}

		vim.g.vimtex_matchparen_enabled = 0 -- Disable VimTeX's parenthesis matching (can conflict with other plugins)

		-- Auto-command to clean auxiliary files when leaving a TeX buffer
		vim.api.nvim_create_autocmd("VimLeavePre", {
			pattern = "*.tex",
			callback = function()
				vim.cmd("VimtexClean") -- Run VimtexClean command
			end,
		})
	end,
	keys = {
		-- Keymaps for common VimTeX actions (all specific to 'tex' filetype)
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
