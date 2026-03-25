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
				icons_enabled = true,
				always_divide_middle = false,
				disabled_filetypes = {
					statusline = { "dashboard", "alpha" },
				},
			},
			sections = {
				-- Left-aligned section A
				lualine_a = {
					{
						"mode", -- Display current Vim mode
						icon = "", -- Icon for mode
						padding = 0, -- No padding around the mode component
						color = function() -- Dynamically change mode color
							local mode_color = {
								n = "#31748f", -- Normal mode
								i = "#9ccfd8", -- Insert mode
								v = "#c4a7e7", -- Visual mode (character-wise)
								V = "#f6c177", -- Visual mode (line-wise)
								c = "#eb6f92", -- Command-line mode
								R = "#ebbcba", -- Replace mode
							}
							local mode = vim.fn.mode()
							return {
								fg = mode_color[mode] or "#6e6a86", -- Fallback color if mode not defined
								bg = "none",
								gui = "bold",
							}
						end,
					},
				},
				-- Left-aligned section B
				lualine_b = {
					{ "branch", icon = "", color = { bg = "none" } }, -- Git branch name
					{ "diff", color = { bg = "none" } }, -- Git diff status (added, changed, removed)
					{ "diagnostics", color = { bg = "none" } }, -- LSP diagnostics (errors, warnings, info)
				},
				-- Middle section C
				lualine_c = {
					{
						"filename", -- Current buffer filename
						path = 0, -- Show only filename, no full path
						symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" }, -- Symbols for file status
						color = { bg = "none" },
					},
					{ "lsp_progress", color = { bg = "none" } }, -- LSP progress indicator
				},
				-- Right-aligned section X
				lualine_x = {
					{ "filetype", icon_only = false, color = { bg = "none" }, padding = 0 }, -- Current file type
				},
				lualine_y = {}, -- Empty section
				lualine_z = {}, -- Empty section
			},
			inactive_sections = { -- What to show in inactive window statuslines
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" }, -- Only filename in inactive windows
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			extensions = {}, -- No extensions explicitly enabled here
		})
	end,
}
