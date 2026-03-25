local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node

local manual_snippets = {

	s("sm", {
		t({
			"\\documentclass{article}",
			"\\usepackage[utf8]{inputenc}",
			"\\usepackage{amsmath}",
			"\\usepackage{graphicx}",
			"\\usepackage{subcaption} % para poder poner una figura al lado de otra",
			"\\usepackage[margin=2.5cm]{geometry} % margenes a 2.5cm",
			"\\usepackage[spanish, provide=*]{babel}",
			"",
			"\\title{",
		}),
		i(1, "Mi Título"),
		t({
			"}",
			"\\author{",
		}),
		i(2, "Mi Nombre"),
		t({
			"}",
			"\\date{\\today}",
			"",
			"\\begin{document}",
			"",
			"\\maketitle",
			"",
			"\\vspace{5cm}",
			"",
			"\\tableofcontents",
			"",
		}),
		i(0),
		t({
			"",
			"\\end{document}",
		}),
	}),

	s("fig", {
		t("\\begin{figure}[h!]"),
		t({ "", "\t\\centering" }),
		t({ "", "\t\\includegraphics[width=0.8\\textwidth]{" }),
		i(1, "graficas/mi-imagen.png"),
		t({ "}", "" }),
		t({ "\t\\caption{" }),
		i(2, "Pie de foto"),
		t({ "}", "" }),
		t({ "\t\\label{fig:" }),
		i(3, "mi-etiqueta"),
		t({ "}", "" }),
		t("\\end{figure}"),
		i(0),
	}),

	s("beg", {
		t("\\begin{"),
		i(1),
		t({ "}", "\t" }),
		i(0),
		t({ "", "\\end{" }),
		f(function(args, _)
			return args[1]
		end, { 1 }),
		t("}"),
	}),

	s("ali", { t({ "\\begin{align*}", "\t" }), i(1), t({ "", "\\end{align*}" }), i(0) }),
	s("case", { t({ "\\begin{cases}", "\t" }), i(1), t({ "", "\\end{cases}" }), i(0) }),
	s("pmat", { t({ "\\begin{pmatrix}", "\t" }), i(1), t({ "", "\\end{pmatrix}" }), i(0) }),
	s("bmat", { t({ "\\begin{bmatrix}", "\t" }), i(1), t({ "", "\\end{bmatrix}" }), i(0) }),

	s("mk", { t("\\("), i(1), t("\\)"), i(0) }),
	s("dm", { t({ "\\[", "\t" }), i(1), t({ "", "\\]" }), i(0) }),

	s("frac", { t("\\frac{"), i(1), t("}{"), i(2), t("}"), i(0) }),
	s("sqrt", { t("\\sqrt{"), i(1), t("}"), i(0) }),
	s("sq", { t("\\sqrt{"), i(1), t("}"), i(0) }),

	s("ddx", { t("\\frac{\\mathrm{d}}{\\mathrm{d}"), i(1, "x"), t("} "), i(0) }),
	s("part", { t("\\frac{\\partial "), i(1), t("}{\\partial "), i(2), t("}"), i(0) }),

	s("sum", { t("\\sum_{"), i(1, "n=1"), t("}^{"), i(2, "\\infty"), t("} "), i(3), i(0) }),
	s("prod", { t("\\prod_{"), i(1, "n=1"), t("}^{"), i(2, "\\infty"), t("} "), i(3), i(0) }),
	s("lim", { t("\\lim_{"), i(1, "n \\to \\infty"), t("} "), i(0) }),
	s("int", { t("\\int_{"), i(1), t("}^{"), i(2), t("} "), i(3), t(" \\, \\mathrm{d}"), i(4, "x"), i(0) }),

	s("lr", { t("\\left("), i(1), t("\\right)"), i(0) }),
	s("lr(", { t("\\left("), i(1), t("\\right)"), i(0) }),
	s("lr[", { t("\\left["), i(1), t("\\right]"), i(0) }),
	s("lr{", { t("\\left\\{"), i(1), t("\\right\\}"), i(0) }),
	s("abs", { t("\\left|"), i(1), t("\\right|"), i(0) }),
	s("norm", { t("\\left\\|"), i(1), t("\\right\\|"), i(0) }),
	s("hat", { t("\\hat{"), i(1), t("}"), i(0) }),
	s("bar", { t("\\overline{"), i(1), t("}"), i(0) }),
	s("vec", { t("\\vec{"), i(1), t("}"), i(0) }),

	s("set", { t("\\{"), i(1), t("\\}"), i(0) }),
}

local auto_snippets = {

	s("alpha", { t("\\alpha ") }),
	s("beta", { t("\\beta ") }),
	s("gamma", { t("\\gamma ") }),
	s("delta", { t("\\delta ") }),
	s("pi", { t("\\pi ") }),
	s("rho", { t("\\rho ") }),
	s("varrho", { t("\\varrho ") }),
	s("sigma", { t("\\sigma ") }),
	s("theta", { t("\\theta ") }),
	s("tau", { t("\\tau ") }),
	s("omega", { t("\\omega ") }),
	s("Omega", { t("\\Omega ") }),
	s("lambda", { t("\\lambda ") }),
	s("mu", { t("\\mu ") }),

	s("sin", { t("\\sin ") }),
	s("cos", { t("\\cos ") }),
	s("tan", { t("\\tan ") }),
	s("log", { t("\\log ") }),
	s("ln", { t("\\ln ") }),
	s("exp", { t("\\exp ") }),

	s("inf", { t("\\infty ") }),
	s("in", { t("\\in ") }),
	s("notin", { t("\\notin ") }),
	s("forall", { t("\\forall ") }),
	s("AA", { t("\\forall ") }),
	s("exists", { t("\\exists ") }),
	s("EE", { t("\\exists ") }),
	s("subset", { t("\\subset ") }),
	s("cc", { t("\\subset ") }),
	s(":= ", { t("\\coloneqq ") }),
	s("...", { t("\\ldots ") }),
	s("->", { t("\\to ") }),
	s("-->", { t("\\longrightarrow ") }),
	s("=>", { t("\\Rightarrow ") }),
	s("<=>", { t("\\Leftrightarrow ") }),
	s("iff", { t("\\iff ") }),
	s("siff", { t("\\Leftrightarrow ") }),
	s("!=", { t("\\neq ") }),
	s("<=", { t("\\le ") }),
	s(">=", { t("\\ge ") }),
	s("xx", { t("\\times ") }),
	s("**", { t("\\cdot ") }),
	s("sim", { t("\\sim ") }),
	s("~~", { t("\\sim ") }),

	s("RR", { t("\\mathbb{R}") }),
	s("ZZ", { t("\\mathbb{Z}") }),
	s("NN", { t("\\mathbb{N}") }),
	s("QQ", { t("\\mathbb{Q}") }),
	s("CC", { t("\\mathbb{C}") }),

	s("sr", { t("^2") }),
	s("cb", { t("^3") }),
	s("invs", { t("^{-1}") }),
	s("td", { t("^{"), i(1), t("}"), i(0) }),
	s("__", { t("_{"), i(1), t("}"), i(0) }),
}

return {
	manual = manual_snippets,
	auto = auto_snippets,
}
