return {
	"folke/noice.nvim",
	opts = {
		cmdline = { enabled = true, view = "cmdline_popup" },
		notify = { enabled = false }, -- Snacks.notifier toma el relevo
		messages = { enabled = true, view = "notify" },
		popupmenu = { enabled = false },
		lsp = { progress = { enabled = false }, signature = { enabled = false } },
		markdown = { hover = { enabled = false } },
	},
}
