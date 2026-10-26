-- Statusline: lualine con colores de base16 y recarga en cada cambio de paleta
return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "arkav/lualine-lsp-progress" },
	config = function()
		local opts = {
			options = {
				theme = "auto",
				globalstatus = true,
				component_separators = { left = " • ", right = " • " },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { statusline = { "dashboard", "alpha" } },
			},
			sections = {
				lualine_a = { {
					"mode",
					icon = "",
					padding = 0,
					color = function()
						local c = require("base16-colorscheme").colors
						local by_mode = {
							n = c.base0D,
							i = c.base0B,
							v = c.base0E,
							V = c.base0E,
							["\22"] = c.base0E, -- visual bloque
							c = c.base08,
							R = c.base09,
							t = c.base0B,
						}
						return { fg = by_mode[vim.fn.mode()] or c.base03, bg = "none", gui = "bold" }
					end,
				} },
				lualine_b = {
					{ "branch", icon = "", color = { bg = "none" } },
					{ "diff", color = { bg = "none" } },
					{ "diagnostics", color = { bg = "none" } },
				},
				lualine_c = {
					{
						"filename",
						path = 0,
						symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
						color = { bg = "none" },
					},
					{ "lsp_progress", color = { bg = "none" } },
				},
				lualine_x = {},
        lualine_y = { { "location", padding = 1, color = { bg = "none" } } },
				lualine_z = { { "filetype", icon_only = false, padding = 1 } },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
		}

		require("lualine").setup(opts)

		-- core/theme.lua dispara este evento tras cada b16.setup()
		vim.api.nvim_create_autocmd("User", {
			group = vim.api.nvim_create_augroup("lualine-theme", { clear = true }),
			pattern = "ThemeReload",
			callback = function()
				require("lualine").setup(opts)
			end,
		})
	end,
}
