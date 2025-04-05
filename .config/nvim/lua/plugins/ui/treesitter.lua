return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = { enable = true },
				auto_install = true,
				-- cuando se encuentra con un tipo de archivo que no conoce lo instala
				ensure_installed = { "lua" },
				additional_vim_regex_highlighting = false,
				indent = {
					enable = true,
				},
			})
		end,
	},
	{
		"echasnovski/mini.indentscope",
		version = false,
		config = function()
			require("mini.indentscope").setup({
				symbol = "│",
				options = {
					try_as_border = true,
					border = "both",
				},
				draw = {
					delay = 0,
					animation = require("mini.indentscope").gen_animation.none(),
				},
				-- Configuración para el resaltado
				mappings = {
					object_scope = "",
					object_scope_with_border = "",
				},
				highlight = {
					scope = { group = "MiniIndentscopeScope" },
				},
				-- Lista de exclusiones
				modules = {
					-- Filetype exclusions
					filetype = {
						-- Lista de filetypes donde no se mostrará indentscope
						exclude = {
							"help",
							"alpha",
							"dashboard",
							"neo-tree",
							"Trouble",
							"lazy",
							"NvimTree",
							"Telescope",
							"mason",
							"notify",
							"toggleterm",
							"lazyterm",
						},
					},
					-- Buftype exclusions
					buftype = {
						exclude = {
							"terminal",
							"nofile",
							"quickfix",
							"prompt",
						},
					},
				},
			})

			vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#61AFEF" })
			vim.api.nvim_set_hl(0, "MiniIndentscopeScope", {
				bg = "#1F2335",
				underline = true,
				sp = "#7AA2F7",
			})
      -- Evitar que el highlight del tabulado se muestre debajo de pesatañas que no quiero 
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "alpha", "lazy", "mason", "help", "neo-tree", "Trouble", "NvimTree", "Telescope", "notify" },
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},
}
