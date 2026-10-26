local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

return {
	-- If snippetType is autosnippet then it autoactivates
	s({ trig = "mk", snippetType = "autosnippet" }, fmta("$<>$", { i(1) })),

	-- If not it has to be activated
	s({ trig = "cent" }, fmta("#align(center)[<>]", { i(1) })),
}
