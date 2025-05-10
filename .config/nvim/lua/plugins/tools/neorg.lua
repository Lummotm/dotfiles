return {
	"nvim-neorg/neorg",
	lazy = false,
	version = "*",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("neorg").setup({
      build = ":Neorg sync-parsers",
			load = {
				["core.esupports.hop"] = {},
				["core.defaults"] = {},
				["core.concealer"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/Documents/Neorg",
						},
						default_workspace = "notes",
					},
				},
			},
		})
	end,
}
