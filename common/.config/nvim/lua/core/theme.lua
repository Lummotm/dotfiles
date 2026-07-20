-- Theme configuration module

local M = {}

function M.setup()
	vim.opt.termguicolors = true

	-- Transparent backgrounds for floating windows
	vim.schedule(function()
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "BlinkDocumentation", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "BlinkDocumentationBorder", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "MatchParen", { bg = "NONE", fg = "#7aa2f7", underline = true })
		vim.api.nvim_set_hl(0, "Visual", { bg = "#414868", fg = "#ffffff" })
		vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })
	end)

	-- Remove statusline separators for cleaner look
	vim.opt.fillchars:append({ stl = " ", stlnc = " " })

	-- Hide command line, rely on statusline
	vim.opt.cmdheight = 0
end

function M.setup_blink_float(opts)
	if not opts then
		return
	end

	-- Apply rounded borders to Blink completion windows
	opts.completion.documentation.window =
		vim.tbl_deep_extend("force", opts.completion.documentation.window or {}, { border = "rounded", winblend = 0 })
	opts.completion.menu =
		vim.tbl_deep_extend("force", opts.completion.menu or {}, { border = "rounded", winblend = 0 })
	opts.signature.window =
		vim.tbl_deep_extend("force", opts.signature.window or {}, { border = "rounded", winblend = 0 })
end

return M
