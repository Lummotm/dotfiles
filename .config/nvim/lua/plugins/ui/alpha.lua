return {
	"goolord/alpha-nvim",
	config = function()
		require("alpha").setup(require("alpha.themes.dashboard").config)
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Configura los botones
		dashboard.section.buttons.val = {
			dashboard.button("f f", "  Find File", ":Telescope find_files<CR>"),
			dashboard.button("f h", "  Recent Files", ":Telescope oldfiles<CR>"),
			dashboard.button("f r", "  Frecency", ":Telescope frecency<CR>"),
			dashboard.button("f g", "  Find Word", ":Telescope live_grep<CR>"),
		}

		alpha.setup(dashboard.config)
	end,
}
