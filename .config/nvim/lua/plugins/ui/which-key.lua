return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "+",
			ellipsis = "…",
			mappings = false,
			rules = {},
			colors = true,
			keys = {},
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},

	config = function(_, opts) --ignore "plugin" argument with _ (load opts with second argument)
		require("which-key").setup(opts)
		require("which-key").add({
			{ "<leader>c", group = "[C]ode" },
			{ "<leader>e", group = "[E]xplorer" },
			{ "<leader>f", group = "[P]icker" },
			{ "<leader>g", group = "[S]tylers" },
		})
	end,
}
