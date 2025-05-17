return {
	"folke/which-key.nvim",
	event = "UIEnter",
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
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = true })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},

	-- which-key groups defined here
	config = function(_, opts) --ignore "plugin" argument with _ (load opts with second argument)
		require("which-key").setup(opts)
		require("which-key").add({
			{ "<leader>c", group = "[C]ode" },
			{ "<leader>e", group = "[E]xplorer" },
			{ "<leader>f", group = "[P]icker" },
			{ "<leader>s", group = "[S]tylers" },
			{ "<leader>g", group = "[G]it" },
		})
	end,
}
