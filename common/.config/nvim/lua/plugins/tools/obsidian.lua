return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*",
		ft = "markdown", -- Load only for markdown files
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			-- Markdown-specific keymaps
			{
				"gf",
				function()
					return require("obsidian").util.gf_passthrough()
				end,
				ft = "markdown",
				expr = true,
				desc = "Follow obsidian link",
			},
			{
				"<cr>",
				function()
					return require("obsidian").util.smart_action()
				end,
				ft = "markdown",
				expr = true,
				desc = "Smart action (follow link or toggle checkbox)",
			},
			{
				"<leader>ch",
				function()
					return require("obsidian").util.toggle_checkbox()
				end,
				ft = "markdown",
				desc = "Toggle checkbox",
			},
		},
		vim.keymap.set("n", "<leader>oo", function()
			local filepath = vim.fn.expand("%:p")
			local url = "obsidian://open?path=" .. vim.fn.fnamemodify(filepath, ":p")

			-- Ejectumos desacoplando
			vim.fn.jobstart({ "xdg-open", url }, { detach = true })
		end, { desc = "Open in Obsidian", noremap = true, silent = true }),

		opts = {
			legacy_commands = false,
			workspaces = {
				{
					name = "obsidian",
					path = vim.fn.resolve("/home/davidn/Documents/Obsidian/"),
				},
			},
			-- notes_subdir = "01 - quicknotes",
			-- daily_notes = {
			-- 	folder = "02 - journal",
			-- 	date_format = "%d-%m-%y",
			-- 	alias_format = "%b %-d, %y",
			-- 	default_tags = { "daily-notes" },
			-- },
			completion = {
				blink = true,
				min_chars = 1,
			},
			-- templates = {
			-- 	folder = "99 - templates",
			-- 	date_format = "%y-%m-%d",
			-- 	time_format = "%h:%m",
			-- 	substitutions = {},
			-- },
			open_notes_in = "current",
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		ft = { "markdown" },
		keys = {
			{ "<leader>op", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
		},
	},
}
