-- Blink.cmp: Modern completion engine
-- Provides LSP completions, snippets, fuzzy search, and signature help

return {
	"saghen/blink.cmp",
	version = "v0.*",
	dependencies = {
		"L3MON4D3/LuaSnip", -- Snippet engine
		"rafamadriz/friendly-snippets", -- Predefined snippets
	},
	event = { "BufReadPre", "BufNewFile" },

	opts = {
		-- Keybindings: How to interact with completion popup
		keymap = {
			preset = "default",
			["<C-e>"] = { "accept", "fallback" }, -- Accept completion
			["<Tab>"] = { "snippet_forward", "fallback" }, -- Next snippet placeholder
			["<S-Tab>"] = { "snippet_backward", "fallback" }, -- Prev snippet placeholder
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" }, -- Toggle completion
		},

		-- Completion appearance and behavior
		completion = {
			-- Auto-insert first match without extra keypress
			list = { selection = { auto_insert = true } },

			-- Documentation popup on hover
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				window = {
					border = "rounded",
					winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
				},
			},

			-- Completion menu styling
			menu = {
				border = "rounded",
				draw = { gap = 2 },
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
			},

			-- Ghost text: Show next line of completion inline
			ghost_text = { enabled = true },
		},

		-- Command line completion (e.g., :w, :e)
		cmdline = {
			enabled = true,
			keymap = { preset = "inherit" },
			completion = { menu = { auto_show = true } },
		},

		-- Sources: Where to get completions from
		sources = {
			default = { "lsp", "snippets", "path" },
			per_filetype = {
				markdown = { "lsp", "snippets", "buffer", "path" },
				tex = { "lsp", "snippets", "buffer", "path" },
			},

			providers = {
				lsp = { name = "LSP", module = "blink.cmp.sources.lsp", score_offset = 100 },
				snippets = {},
				buffer = { score_offset = -3 },
			},
		},

		-- Snippet expansion engine
		snippets = { preset = "luasnip" },

		-- Fuzzy matching configuration
		fuzzy = { sorts = { "exact", "score" } },

		-- Function signature display (when calling functions)
		signature = {
			enabled = true,
			window = { border = "rounded", winblend = 0, show_documentation = false },
		},
	},
}
