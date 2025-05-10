return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		picker = { enabled = true },
		explorer = { enabled = false },
		image = { enabled = false },
		indent = { enabled = true },
		notify = { enabled = true },
		notifier = { enabled = true },
		dashboard = { enabled = true },
		scroll = { enabled = true },
		bigfile = { enabled = true },
		input = { enabled = true },
		scope = { enabled = true },
		words = { enabled = true },
		statuscolumn = { enabled = true },
		quickfile = { enabled = true },
	},
	keys = {
		-- Pickers
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Find Config File",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fp",
			function()
				Snacks.picker.projects()
			end,
			desc = "Projects",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},

		-- LSP
		{
			"gd",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Goto Definition",
		},
		{
			"gr",
			function()
				Snacks.picker.lsp_references()
			end,
			desc = "References",
		},

		-- Explorer
		{
			"<leader>ef",
			function()
				Snacks.explorer()
			end,
			desc = "Snacks: file Explorer",
		},

		-- Notifier
		{
			"<leader>n",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification History",
		},
	},
}
