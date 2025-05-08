local M = {}

function M.setup()
	-- obliga a usar true color en el terminal
	vim.opt.termguicolors = true

	-- carga el tema
	vim.cmd("colorscheme catppuccin-mocha")

	-- quita el fondo de las ventanas y floats
	vim.schedule(function()

		-- floats (WhichKey)
		vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

		-- opcional: otras cosas que te molesten
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })
	end)

	-- colores de paréntesis y selección
	vim.api.nvim_set_hl(0, "MatchParen", {
		bg = "NONE",
		fg = "#7aa2f7",
		underline = true,
	})
	vim.api.nvim_set_hl(0, "Visual", {
		bg = "#414868",
		fg = "#ffffff",
	})
	vim.opt.fillchars:append({
		-- stl  = statusline (ventana activa)
		-- stlnc = statusline en ventanas inactivas
		stl = " ",
		stlnc = " ",
	})
  vim.opt.cmdheight = 0
end

return M
