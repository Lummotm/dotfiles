local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

-- 1. DETECCIÓN DE ZONA MATEMÁTICA "TODO TERRENO"
local function in_mathzone()
	local has_ts, ts = pcall(require, "vim.treesitter")
	if not has_ts then
		return false
	end

	local node = ts.get_node({ ignore_injections = false })
	while node do
		local type = node:type()
		-- Añadimos 'block_continuation' y 'displayed_equation' que a veces usa MD
		if
			type == "latex_block"
			or type == "inline_formula"
			or type == "math_environment"
			or type == "math_span"
			or type == "formula"
			or type == "displayed_equation"
		then
			return true
		end
		node = node:parent()
	end
	return false
end

local manual_snippets = {
	s("beg", {
		t("\\begin{"),
		i(1),
		t({ "}", "\t" }),
		i(0),
		t({ "", "\\end{" }),
		rep(1),
		t("}"),
	}),
}

local auto_snippets = {
	-- DISPARADORES DE BLOQUE (Basados en tu config de Obsidian)
	s({ trig = "mk", snippetType = "autosnippet" }, { t("$"), i(1), t("$") }),
	s({ trig = "dm", snippetType = "autosnippet" }, { t({ "$$", "" }), i(1), t({ "", "$$" }) }),

	-- Al escribir '^' o '_' dentro de mate, se pone '^{}' o '_{}'
	s({ trig = "^", snippetType = "autosnippet" }, { t("^{"), i(1), t("}"), i(0) }, { condition = in_mathzone }),
	s({ trig = "_", snippetType = "autosnippet" }, { t("_{"), i(1), t("}"), i(0) }, { condition = in_mathzone }),

	-- NUEVOS: LÍMITE Y SUMA
	s(
		{ trig = "lim", snippetType = "autosnippet" },
		{ t("\\lim_{"), i(1, "n"), t(" \\to "), i(2, "\\infty"), t("} "), i(0) },
		{ condition = in_mathzone }
	),

	s(
		{ trig = "sum", snippetType = "autosnippet" },
		{ t("\\sum_{"), i(1, "i=1"), t("}^{"), i(2, "n"), t("} "), i(0) },
		{ condition = in_mathzone }
	),

	-- OPERACIONES (mA)
	s({ trig = "sr", snippetType = "autosnippet" }, { t("^{2}") }, { condition = in_mathzone }),
	s({ trig = "cb", snippetType = "autosnippet" }, { t("^{3}") }, { condition = in_mathzone }),
	s({ trig = "rd", snippetType = "autosnippet" }, { t("^{"), i(1), t("}"), i(0) }, { condition = in_mathzone }),
	s({ trig = "_", snippetType = "autosnippet" }, { t("_{"), i(1), t("}"), i(0) }, { condition = in_mathzone }),
	s(
		{ trig = "//", snippetType = "autosnippet" },
		{ t("\\frac{"), i(1), t("}{"), i(2), t("}") },
		{ condition = in_mathzone }
	),
	s({ trig = "ee", snippetType = "autosnippet" }, { t("e^{"), i(1), t("}"), i(0) }, { condition = in_mathzone }),
	s(
		{ trig = "sq", snippetType = "autosnippet" },
		{ t("\\sqrt{ "), i(1), t(" }"), i(0) },
		{ condition = in_mathzone }
	),

	-- SÍMBOLOS
	s({ trig = "ooo", snippetType = "autosnippet" }, { t("\\infty") }, { condition = in_mathzone }),
	s({ trig = "=>", snippetType = "autosnippet" }, { t("\\implies") }, { condition = in_mathzone }),
	s({ trig = "->", snippetType = "autosnippet" }, { t("\\to") }, { condition = in_mathzone }),
	s({ trig = "inn", snippetType = "autosnippet" }, { t("\\in") }, { condition = in_mathzone }),
	s({ trig = "RR", snippetType = "autosnippet" }, { t("\\mathbb{R}") }, { condition = in_mathzone }),
	s({ trig = "CC", snippetType = "autosnippet" }, { t("\\mathbb{C}") }, { condition = in_mathzone }),
	s({ trig = "ZZ", snippetType = "autosnippet" }, { t("\\mathbb{Z}") }, { condition = in_mathzone }),
	s({ trig = "NN", snippetType = "autosnippet" }, { t("\\mathbb{N}") }, { condition = in_mathzone }),
}

-- BUCLES DINÁMICOS PARA GRIEGAS Y MÁS

-- Griegas: @a -> \alpha
local greek = {
	a = "alpha",
	b = "beta",
	g = "gamma",
	G = "Gamma",
	d = "delta",
	D = "Delta",
	e = "epsilon",
	z = "zeta",
	t = "theta",
	T = "Theta",
	l = "lambda",
	L = "Lambda",
	s = "sigma",
	S = "Sigma",
	u = "upsilon",
	o = "omega",
	O = "Omega",
}
for k, v in pairs(greek) do
	table.insert(
		auto_snippets,
		s({ trig = "@" .. k, snippetType = "autosnippet" }, { t("\\" .. v) }, { condition = in_mathzone })
	)
end

-- Subíndices: x1 -> x_{1}
table.insert(
	auto_snippets,
	s(
		{
			trig = "([%a])(%d)",
			regTrig = true,
			wordTrig = false,
			snippetType = "autosnippet",
		},
		f(function(_, snip)
			return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
		end),
		{ condition = in_mathzone }
	)
)

-- Funciones: sin -> \sin
local funcs = { "sin", "cos", "tan", "ln", "log", "exp", "det" }
for _, func in ipairs(funcs) do
	table.insert(
		auto_snippets,
		s(
			{
				trig = "(^|[^%a\\])" .. func,
				regTrig = true,
				wordTrig = false,
				snippetType = "autosnippet",
			},
			f(function(_, snip)
				return snip.captures[1] .. "\\" .. func
			end),
			{ condition = in_mathzone }
		)
	)
end

-- Modificadores: xhat -> \hat{x}
local mods = { hat = "\\hat", bar = "\\bar", dot = "\\dot", tilde = "\\tilde", vec = "\\vec" }
for k, v in pairs(mods) do
	table.insert(
		auto_snippets,
		s(
			{
				trig = "([%a])" .. k,
				regTrig = true,
				wordTrig = false,
				snippetType = "autosnippet",
			},
			f(function(_, snip)
				return v .. "{" .. snip.captures[1] .. "}"
			end),
			{ condition = in_mathzone }
		)
	)
end

return manual_snippets, auto_snippets
