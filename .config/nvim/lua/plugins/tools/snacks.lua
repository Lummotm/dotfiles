return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		picker = {
			enabled = true,
			matcher = {
				fuzzy = true, -- use fuzzy matching
				smartcase = true, -- use smartcase
				ignorecase = true, -- use ignorecase
				sort_empty = false, -- sort results when the search string is empty
				filename_bonus = true, -- give bonus for matching file names (last part of the path)
				file_pos = true, -- support patterns like `file:line:col` and `file:line`
				-- the bonusses below, possibly require string concatenation and path normalization,
				-- so this can have a performance impact for large lists and increase memory usage
				cwd_bonus = false, -- give bonus for matching files in the cwd
				frecency = false, -- frecency bonus
				history_bonus = false, -- give more weight to chronological order
				hidden = true,
			},
			sort = {
				-- default sort is by score, text length and index
				fields = { "score:desc", "#text", "idx" },
			},
			files = {
				find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" },
				follow_links = true,
			},
		},
		explorer = { enabled = false },
		image = { enabled = false },
		indent = { enabled = true },
		notify = { enabled = true },
		notifier = { enabled = true },
		dashboard = {
			enabled = true,
			preset = {
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{ icon = " ", key = "e", desc = "Open Yazi Explorer", action = "<cmd>Yazi<CR>" },
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{
						icon = "󰒲 ",
						key = "L",
						desc = "Lazy",
						action = ":Lazy",
						enabled = package.loaded.lazy ~= nil,
					},
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
		scroll = { enabled = true },
		bigfile = { enabled = true },
		input = { enabled = true },
		scope = { enabled = true },
		words = { enabled = true },
		statuscolumn = { enabled = true },
		quickfile = { enabled = true },
		lazygit = { enabled = true },
	},
	keys = {
		{
			"<leader>gg",
			function()
				require("snacks").lazygit()
			end,
			desc = "Open LazyGit",
		},
		{
			"<leader>fb",
			function()
				require("snacks").picker.buffers()
			end,
			desc = "Buffer List",
		},
		{
			"<leader>fc",
			function()
				require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Find Config File",
		},
		{
			"<leader>ff",
			function()
				require("snacks").picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fp",
			function()
				require("snacks").picker.projects()
			end,
			desc = "Projects",
		},
		{
			"<leader>fr",
			function()
				require("snacks").picker.recent()
			end,
			desc = "Recent Files",
		},
		{
			"<leader>fg",
			function()
				require("snacks").picker.grep()
			end,
			desc = "Grep Text",
		},
		{
			"<leader>fk",
			function()
				require("snacks").picker.keymaps()
			end,
			desc = "Find Keymaps",
		},
		{
			"gd",
			function()
				require("snacks").picker.lsp_definitions()
			end,
			desc = "Go to Definition",
		},
		{
			"gD",
			function()
				require("snacks").picker.lsp_declarations()
			end,
			desc = "Go to Declaration",
		},
		{
			"gr",
			function()
				require("snacks").picker.lsp_references()
			end,
			desc = "References",
		},
		{
			"gI",
			function()
				require("snacks").picker.lsp_implementations()
			end,
			desc = "Go to Implementation",
		},
		{
			"gy",
			function()
				require("snacks").picker.lsp_type_definitions()
			end,
			desc = "Go to Type Definition",
		},
		{
			"<leader>nh",
			function()
				require("snacks").notifier.show_history()
			end,
			desc = "Notification History",
		},
	},
}
