-- Core keybindings (sin dependencias de plugins)

local map = vim.keymap.set

-- CLIPBOARD
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Copy line to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

-- SCROLL (centrado)
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- QUIT
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- SPELL: ES -> EN -> OFF
map("n", "<leader>ss", function()
	if not vim.wo.spell then
		vim.wo.spell = true
		vim.bo.spelllang = "es"
		print("Spellcheck: ES")
	elseif vim.bo.spelllang == "es" then
		vim.bo.spelllang = "en"
		print("Spellcheck: EN")
	else
		vim.wo.spell = false
		print("Spellcheck: OFF")
	end
end, { desc = "Toggle Spell (ES/EN/OFF)" })

-- BUFFERS
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<CR>", { desc = "Force delete buffer" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bw", "<cmd>w!<CR>", { desc = "Save buffer" })
map("n", "<leader>ba", [[<cmd>%bdelete|edit #|normal `"<CR>]], { desc = "Delete all except current" })

-- Buffers abiertos en quickfix (el <CR> especial vive en autocmds.lua)
map("n", "<leader>bb", function()
	local items = {}
	for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if buf.name ~= "" then
			table.insert(items, {
				filename = buf.name,
				lnum = 1,
				col = 1,
				text = "Buffer: " .. buf.name,
			})
		end
	end

	vim.fn.setqflist({}, " ", {
		title = "Buffers",
		items = items,
		context = { is_buffer_qf = true },
	})
	vim.cmd("copen")
end, { desc = "Open buffers in quickfix" })

-- WINDOWS
map("n", "<leader>wh", "<C-w>h", { desc = "Move to left window" })
map("n", "<leader>wj", "<C-w>j", { desc = "Move to lower window" })
map("n", "<leader>wk", "<C-w>k", { desc = "Move to upper window" })
map("n", "<leader>wl", "<C-w>l", { desc = "Move to right window" })
map("n", "<leader>ws", "<C-w>v", { desc = "Split vertically" })
map("n", "<leader>wv", "<C-w>s", { desc = "Split horizontally" })
map("n", "<leader>we", "<C-w>=", { desc = "Equalize windows" })
map("n", "<leader>wq", "<C-w>q", { desc = "Close window" })
map("n", "<leader>wx", "<C-w>x", { desc = "Swap with next window" })

-- CODE
map("n", "<leader>ci", "gg=G", { desc = "Auto-indent entire file" })

map("n", "<leader>cf", function()
	local ok, conform = pcall(require, "conform")
	if ok then
		conform.format({ async = true })
	else
		vim.lsp.buf.format()
	end
end, { desc = "Format buffer (conform/LSP)" })

map("n", "<leader>ct", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat
	print("Auto-format on save: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
end, { desc = "Toggle auto-format on save" })

-- COMPILE
local compile = require("core.compile")
map("n", "<leader>cc", compile.compile, { desc = "Compile" })
map("n", "<leader>cr", compile.run, { desc = "Run" })
map("n", "<leader>cR", compile.reset, { desc = "Reset compile/run command" })
map("n", "<leader>cw", compile.focus, { desc = "Toggle focus on compile terminal" })

-- DIAGNOSTICS: toggle loclist
map("n", "gl", function()
	local info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
	if info and info.loclist == 1 then
		vim.cmd("lclose")
		return
	end

	vim.diagnostic.setloclist()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.fn.getwininfo(win)[1].loclist == 1 then
			vim.api.nvim_set_current_win(win)
			break
		end
	end
end, { desc = "Toggle diagnostics loclist" })
