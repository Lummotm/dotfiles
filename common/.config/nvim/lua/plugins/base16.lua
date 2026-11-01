-- lua/plugins/base16.lua
return {
	"RRethy/base16-nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("core.theme").setup()
	end,
}
