-- Obsidian: Obsidian.md integration for note-taking
return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*",
		ft = "markdown",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
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
				desc = "Smart action",
			},
			{
				"<leader>ch",
				function()
					return require("obsidian").util.toggle_checkbox()
				end,
				ft = "markdown",
				desc = "Toggle checkbox",
			},
			{
				"<leader>oo",
				function()
					local filepath = vim.fn.expand("%:p")
					local url = "obsidian://open?path=" .. vim.fn.fnamemodify(filepath, ":p")
					vim.fn.jobstart({ "xdg-open", url }, { detach = true })
				end,
				desc = "Open in Obsidian",
			},
		},
		opts = {
			legacy_commands = false,
			workspaces = { { name = "obsidian", path = vim.fn.resolve("/home/davidn/Documents/Obsidian/") } },
			completion = { min_chars = 1, match_case = true },
			open_notes_in = "current",
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		ft = { "markdown" },
		keys = { { "<leader>op", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" } },
	},
}
