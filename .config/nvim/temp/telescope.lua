return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x", -- Versión estable
		dependencies = {
			"nvim-lua/plenary.nvim", -- Obligatorio
			"nvim-treesitter/nvim-treesitter", -- Opcional (mejora resaltado)
			"nvim-telescope/telescope-live-grep-args.nvim",
			"andrew-george/telescope-themes",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				pickers = {
					find_files = {
						theme = "ivy",
					},
				},

				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
						case_mode = "smart_case", -- or "ignore_case" or "respect_case"
						-- the default case_mode is "smart_case"
					},
				},
			})
			telescope.load_extension("themes")
			telescope.load_extension("fzf")
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
	{
		"nvim-telescope/telescope-frecency.nvim",
		dependencies = { "kkharji/sqlite.lua" },
		-- install the latest stable version
		version = "*",
		config = function()
			require("telescope").setup({
				extensions = {
					frecency = {
						show_scores = false,
						show_unindexed = true,
						ignore_patterns = { ".git/*", "*/temp/*" },
						disable_devicons = false,
					},
				},
			})
			require("telescope").load_extension("frecency")
		end,
	},
}
