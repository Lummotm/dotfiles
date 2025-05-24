return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		lazy = true,
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {

			vim.keymap.set("n", "<leader>gn", function()
				vim.fn.system("sync-notes")
				print("Notas sincronizadas.")
			end, { desc = "Sincronizar notas Obsidian" }),

			vim.keymap.set("n", "<leader>ob", function()
				local input = vim.fn.expand("%")
				local output = "/tmp/preview.html"
				local cmd = {
					"pandoc",
					input,
					"-s",
					"--mathjax=https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js",
					"-o",
					output,
				}

				vim.fn.jobstart(cmd, {
					on_exit = function()
						vim.fn.jobstart({ "zen-browser", output }, { detach = true })
					end,
				})
			end, { desc = "Preview Markdown with LaTeX in Zen", noremap = true, silent = true }),

			vim.keymap.set("n", "<leader>oo", function()
				local path = vim.fn.expand("%:~:.")
				local rel = path:gsub("^.*Obsidian/", "")
				local encoded = rel:gsub(" ", "%%20")
				local vault = "Obsidian"
				local url = "obsidian://open?vault=" .. vault .. "&file=" .. encoded
				vim.fn.jobstart({ "xdg-open", url }, { detach = true })
			end, { desc = "Open current file in Obsidian" }),
		},

		config = function()
			require("obsidian").setup({
				workspaces = {
					{
						name = "Obsidian",
						path = "~/Documents/Obsidian/",
					},
				},
				notes_subdir = "001 - inbox",
				daily_notes = {
					folder = "002 - journal",
					date_format = "%d-%m-%y",
					alias_format = "%B %-d, %Y",
					default_tags = { "daily-notes" },
					template = nil,
				},
				completion = {
					blink = true,
					min_chars = 1,
				},
				mappings = {
					-- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
					["gf"] = {
						action = function()
							return require("obsidian").util.gf_passthrough()
						end,
						opts = { noremap = false, expr = true, buffer = true },
					},
					-- Toggle check-boxes.
					["<leader>ch"] = {
						action = function()
							return require("obsidian").util.toggle_checkbox()
						end,
						opts = { buffer = true },
					},
					-- Smart action depending on context: follow link, show notes with tag, toggle checkbox, or toggle heading fold
					["<cr>"] = {
						action = function()
							return require("obsidian").util.smart_action()
						end,
						opts = { buffer = true, expr = true },
					},
				},
				templates = {
					folder = "999 - templates",
					date_format = "%Y-%m-%d",
					time_format = "%H:%M",
					-- A map for custom variables, the key should be the variable and the value a function
					substitutions = {},
				},
				picker = {
					name = "snacks.pick",
					note_mappings = {
						-- Create a new note from your query.
						new = "<C-x>",
						-- Insert a link to the selected note.
						insert_link = "<C-l>",
					},
					tag_mappings = {
						-- Add tag(s) to current note.
						tag_note = "<C-x>",
						-- Insert a tag at the current location.
						insert_tag = "<C-l>",
					},
				},
				open_notes_in = "current",
			})
		end,
	},
}
