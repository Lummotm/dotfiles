local M = {}

function M.setup()
	-- ╭─────────────────────────────────────────────╮
	-- │ Theme Setup                                 │
	-- ╰─────────────────────────────────────────────╯

	-- Force true color support
	vim.opt.termguicolors = true

	-- ╭─────────────────────────────────────────────╮
	-- │ UI Highlight Customization                  │
	-- ╰─────────────────────────────────────────────╯
	vim.schedule(function()
		-- Transparent background for floats (e.g., WhichKey)
		vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

		-- Optional: make sign column and cursor line transparent
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })
	end)

	-- MatchParen styling
	vim.api.nvim_set_hl(0, "MatchParen", {
		bg = "NONE",
		fg = "#7aa2f7",
		underline = true,
	})

	-- Visual selection styling
	vim.api.nvim_set_hl(0, "Visual", {
		bg = "#414868",
		fg = "#ffffff",
	})

	-- Remove statusline chars (cleaner look)
	vim.opt.fillchars:append({
		stl = " ",
		stlnc = " ",
	})

	-- Hide command line (optional)
	vim.opt.cmdheight = 0
end

return M
