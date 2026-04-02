-- Motor de autocompletado (LSP, snippets, path)
return {
	"saghen/blink.cmp",
	version = "v0.*",
	dependencies = {
		"L3MON4D3/LuaSnip",
		"rafamadriz/friendly-snippets",
	},
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		keymap = {
			preset = "default",
			["<C-e>"] = { "accept", "fallback" },
			["<Tab>"] = { "snippet_forward", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "fallback" },
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		},

		completion = {
			list = { selection = { auto_insert = true } },
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				window = {
					border = "rounded",
					winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
				},
			},
			menu = {
				border = "rounded",
				draw = { gap = 2 },
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
			},
			ghost_text = { enabled = true },
		},

		cmdline = {
			enabled = true,
			keymap = { preset = "inherit" },
			completion = { menu = { auto_show = true } },
		},

		sources = {
			default = { "lsp", "snippets", "buffer", "path" },
			providers = {
				lsp = {
					name = "LSP",
					module = "blink.cmp.sources.lsp",
					score_offset = 100,
				},
				snippets = {},
				buffer = {
					score_offset = -3,
				},
			},
		},

		snippets = {
			preset = "luasnip",
		},
		fuzzy = {
			sorts = {
				"exact",
				"score",
				"sort_text",
			},
		},

		signature = {
			enabled = true,
			window = {
				border = "rounded",
				winblend = 0,
				show_documentation = false,
			},
		},
	},
}
