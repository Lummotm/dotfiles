return {
	"folke/noice.nvim",
	opts = {
		cmdline = { enabled = true, view = "cmdline_popup" },
		notify = { enabled = false },
		messages = {
			enabled = true,
			view = "notify",
		},
		popupmenu = { enabled = false },
		lsp = {
			progress = { enabled = false },
			signature = { enabled = false },
		},
		markdown = { hover = { enabled = false } },
		routes = {
			{
				view = "notify",
				filter = { event = "msg_showmode" },
			},
		},
	},
}
