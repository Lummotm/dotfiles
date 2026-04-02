-- Hace lo del CMD-Line el medio y gestiona notfiicaciones, ns pq no se junta con snacks
return {
	"folke/noice.nvim",
	event = "VeryLazy",
	priority = 1000,
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		cmdline = { enabled = true, view = "cmdline_popup" },
		lsp = {
			documentation = { enabled = false },
			signature = { enabled = false },
			hover = { enabled = false },
		},
	},
}
