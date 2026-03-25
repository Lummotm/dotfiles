return {
	"L3MON4D3/LuaSnip",
	event = "InsertEnter",
	config = function()
		local ls = require("luasnip")

		-- Activate autosnippets globally
		ls.setup({
			enable_autosnippets = true,
		})

		-- Loads automatically all snippets when a file is opened
		-- for example if a .typ one is opened, then it searches for snippets/typst.lua
		require("luasnip.loaders.from_lua").lazy_load({
			paths = { "./lua/snippets" },
		})
	end,
}
