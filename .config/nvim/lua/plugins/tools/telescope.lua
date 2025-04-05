return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x", -- Versión estable
		dependencies = {
			"nvim-lua/plenary.nvim", -- Obligatorio
			"nvim-treesitter/nvim-treesitter", -- Opcional (mejora resaltado)
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				find_files = {
					theme = "dropdown", -- Interfaz con menú desplegable
					hidden = true, -- Incluye archivos ocultos (ej: .gitignore)
				},
			})
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
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		lazy = true,
		dependencies = {
			"andrew-george/telescope-themes",
			-- other dependencies
		},
		config = function()
			-- load extension
			local telescope = require("telescope")
			telescope.load_extension("themes")
		end,
	},
}
