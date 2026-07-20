-- Statusline: Lightweight statusline with LSP progress
return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "arkav/lualine-lsp-progress" },
	config = function()
		require("lualine").setup({
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
					icon = "",
					padding = 0,
					color = function()
						local mode_color = {
							n = "#31748f", i = "#9ccfd8", v = "#c4a7e7",
							V = "#f6c177", c = "#eb6f92", R = "#ebbcba",
						}
						local mode = vim.fn.mode()
						return { fg = mode_color[mode] or "#6e6a86", bg = "none", gui = "bold" }
					end,
				} },
				lualine_b = {
					{ "branch", icon = "", color = { bg = "none" } },
					{ "diff", color = { bg = "none" } },
					{ "diagnostics", color = { bg = "none" } },
				},
				lualine_c = { {
					"filename",
					path = 0,
					symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
					color = { bg = "none" },
				}, { "lsp_progress", color = { bg = "none" } } },
				lualine_x = {},
				lualine_y = { { "location", padding = 1 } },
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
		})
	end,
}
