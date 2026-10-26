-- Blink.cmp: completado (LSP, snippets, path, cmdline)

return {
	"saghen/blink.cmp",
	version = "1.*",
	dependencies = {
		"L3MON4D3/LuaSnip",
		"rafamadriz/friendly-snippets",
	},
	event = { "InsertEnter", "CmdlineEnter" },

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
				window = { border = "rounded" },
			},
			menu = { border = "rounded", draw = { gap = 2 } },
			ghost_text = { enabled = true },
		},

		cmdline = {
			keymap = { preset = "inherit" },
			completion = { menu = { auto_show = true } },
		},

		sources = {
			default = { "lsp", "snippets", "path" },
			per_filetype = {
				markdown = { "lsp", "snippets", "buffer", "path" },
				tex = { "lsp", "snippets", "buffer", "path" },
			},
			providers = {
				lsp = { score_offset = 100 },
				buffer = { score_offset = -3 },
			},
		},

		snippets = { preset = "luasnip" },
		fuzzy = { sorts = { "exact", "score" } },
		signature = { enabled = true, window = { border = "rounded" } },
	},
}
