-- Snippets: LuaSnip with friendly-snippets and markdown extension
return {
	"L3MON4D3/LuaSnip",
	event = "InsertEnter",
	config = function()
		local ls = require("luasnip")
		ls.filetype_extend("markdown", { "tex" })
		ls.setup({ enable_autosnippets = true, history = true })
		require("luasnip.loaders.from_lua").lazy_load({
			paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
		})
	end,
}
