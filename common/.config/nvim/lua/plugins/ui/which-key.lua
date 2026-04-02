-- Muestra que keybinds hay seguidas que keys previamente presionadas
return {
	"folke/which-key.nvim",
	event = "VeryLazy", -- Load when the UI is ready
	opts = {
		preset = "modern", -- Use a modern default appearance
		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "+",
			ellipsis = "…",
			mappings = false, -- Don't show icons for individual mappings
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
			desc = "Show all keymaps (Which-Key)", -- Keymap to show all global keybindings
		},
	},

	-- Define keymap groups for better organization
	config = function(_, opts)
		require("which-key").setup(opts)
		require("which-key").add({
			{ "<leader>b", group = "[B]uffer" },
			{ "<leader>c", group = "[C]ode" },
			{ "<leader>e", group = "[E]xplorer" },
			{ "<leader>f", group = "[P]icker" },
			{ "<leader>s", group = "[S]how" },
			{ "<leader>g", group = "[G]it" },
			{ "<leader>w", group = "[W]indow" },
		})
	end,
}
