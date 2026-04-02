-- Utilidades varias (Notificaciones, Pickers,...)
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		picker = {
			enabled = true,
			layout = "custom_default",
			layouts = {
				custom_ivy = {
					layout = {
						box = "vertical",
						backdrop = false,
						row = -1,
						width = 0,
						height = 0.45,
						border = "none",
						title = " {title} {live} {flags}",
						title_pos = "left",
						{
							box = "horizontal",
							{ win = "list", border = "rounded" },
							{ win = "preview", title = "{preview}", width = 0.6, border = "rounded" },
						},
						{ win = "input", height = 1, border = "rounded" },
					},
				},
				custom_default = {
					layout = {
						box = "horizontal",
						width = 0.9,
						min_width = 120,
						height = 0.9,
						{
							box = "vertical",
							border = true,
							title = "{title} {live} {flags}",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
						},
						{ win = "preview", title = "{preview}", border = true, width = 0.5 },
					},
				},
			},
		},
		dashboard = require("plugins.tools.snacks.dashboard"),
		notify = { enabled = true },
		notifier = { enabled = true },
		bigfile = { enabled = true },
		input = { enabled = true },
		scope = { enabled = true },
		quickfile = { enabled = true },
		lazygit = { enabled = false },
		words = { enabled = true },
		image = { enabled = false },
		indent = { enabled = true },
		zen = { enabled = true },
	},
	keys = {
		{
			"<leader>ff",
			function()
				Snacks.picker.files({
					ignored = false,
					follow = true,
				})
			end,
			desc = "Find Files",
			mode = "n",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.grep({
					cmd = "rg",
					ignored = false,
					follow = true,
				})
			end,
			desc = "Live Grep",
			mode = "n",
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Find Buffers",
			mode = "n",
		},
		{
			"<leader>fh",
			function()
				Snacks.picker.help()
			end,
			desc = "Find Help",
			mode = "n",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.files({
					cwd = vim.fn.stdpath("config"),
				})
			end,
			desc = "Find Nvim Config",
			mode = "n",
		},
		{
			"<leader>fk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Keymaps",
			mode = "n",
		},
		{
			"<leader>ft",
			function()
				Snacks.picker.commands()
			end,
			desc = "Commands",
			mode = "n",
		},
		{
			"<leader>fw",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Grep word under cursor",
			mode = "n",
		},
		{
			"<leader>fz",
			function()
				Snacks.picker.zoxide({})
			end,
			desc = "Change dir with zoxide",
			mode = "n",
		},
		{
			"<leader>cd",
			function()
				Snacks.picker.diagnostics_buffer({
					-- Usamos el layout que ya tienes definido o uno vertical para ver mejor el código
					layout = "custom_ivy",
					confirm = function(picker, item)
						picker:close()

						-- Movemos el cursor a la posición del error (fila, columna)
						vim.api.nvim_win_set_cursor(0, { item.pos[1], item.pos[2] })

						vim.schedule(function()
							vim.lsp.buf.code_action()
						end)
					end,
				})
			end,
			desc = "Diagnósticos + Auto Code Actions",
		},
		{
			"<leader>sn",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Show notifications",
			mode = "n",
		},
		{
			"gd",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Goto Definition",
		},
		{
			"gD",
			function()
				Snacks.picker.lsp_declarations()
			end,
			desc = "Goto Declaration",
		},
		{
			"gr",
			function()
				Snacks.picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"gI",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		{
			"gy",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "Goto T[y]pe Definition",
		},
		{
			"<leader>fs",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "LSP Symbols",
		},
		{
			"<leader>fS",
			function()
				Snacks.picker.lsp_workspace_symbols()
			end,
			desc = "LSP Workspace Symbols",
		},
		{
			"<leader>z",
			function()
				Snacks.zen()
			end,
			desc = "Toggle Zen Mode",
		},
		-- {
		-- 	"<leader>gf",
		-- 	function()
		-- 		Snacks.picker.git_files()
		-- 	end,
		-- 	desc = "Git files",
		-- 	mode = "n",
		-- },
		-- {
		-- 	"<leader>gs",
		-- 	function()
		-- 		Snacks.picker.git_status()
		-- 	end,
		-- 	desc = "Git status",
		-- 	mode = "n",
		-- },
		--
		-- {
		-- 	"gai",
		-- 	function()
		-- 		Snacks.picker.lsp_incoming_calls()
		-- 	end,
		-- 	desc = "C[a]lls Incoming",
		-- },
		-- {
		-- 	"gao",
		-- 	function()
		-- 		Snacks.picker.lsp_outgoing_calls()
		-- 	end,
		-- 	desc = "C[a]lls Outgoing",
		-- },
	},
}
