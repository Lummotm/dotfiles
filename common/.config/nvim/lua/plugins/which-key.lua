-- Which-key: Shows available keybindings in a popup
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
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = true })
			end,
			desc = "Show all keymaps",
		},
	},
	config = function(_, opts)
		require("which-key").setup(opts)
		require("which-key").add({
			{ "<leader>b", group = "[B]uffer" },
			{ "<leader>o", group = "[O]verview" },
			{ "<leader>c", group = "[C]ode" },
			{ "<leader>e", group = "[E]xplorer" },
			{ "<leader>f", group = "[P]icker" },
			{ "<leader>s", group = "[S]how" },
			{ "<leader>g", group = "[G]it" },
			{ "<leader>w", group = "[W]indow" },
		})
	end,
}
