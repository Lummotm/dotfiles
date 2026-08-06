-- Core keybindings: Custom mappings for common actions

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- CLIPBOARD
keymap({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
keymap("n", "<leader>Y", '"+Y', { desc = "Copy line to system clipboard" })
keymap({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

-- SCROLL
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- QUIT
keymap("n", "<leader>q", ":q!<CR>", { desc = "Force quit" })

-- SPELL
keymap("n", "<leader>ss", function()
	if not vim.opt.spell:get() then
		vim.opt.spell = true
		vim.opt.spelllang = "es"
		print("Spellcheck: ES")
	elseif vim.opt.spelllang:get()[1] == "es" then
		vim.opt.spelllang = "en"
		print("Spellcheck: EN")
	else
		vim.opt.spell = false
		print("Spellcheck: OFF")
	end
end, { desc = "Toggle Spell (ES/EN/OFF)" })

-- BUFFERS
keymap("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
keymap("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>ba", ':%bdelete|edit #|normal `"<CR>', { desc = "Delete all except current" })
keymap("n", "<leader>bD", ":bdelete!<CR>", { desc = "Force delete buffer" })
keymap("n", "<leader>bw", ":w!<CR>", { desc = "Save buffer" })
vim.keymap.set("n", "<leader>bb", function()
	local buffers = vim.fn.getbufinfo({ buflisted = 1 })
	local qf_items = {}
	for _, buf in ipairs(buffers) do
		if buf.name ~= "" then
			table.insert(qf_items, {
				filename = buf.name,
				lnum = 1,
				col = 1,
				text = "Buffer: " .. buf.name,
			})
		end
	end

	vim.fn.setqflist({}, " ", {
		title = "Buffers",
		items = qf_items,
		context = { is_buffer_qf = true },
	})

	vim.cmd("copen")
end, { desc = "Open open buffers in quickfix list" })

-- WINDOWS
keymap("n", "<leader>wh", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<leader>wj", "<C-w>j", { desc = "Move to lower window" })
keymap("n", "<leader>wk", "<C-w>k", { desc = "Move to upper window" })
keymap("n", "<leader>wl", "<C-w>l", { desc = "Move to right window" })
keymap("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
keymap("n", "<leader>ws", "<C-w>s", { desc = "Split window horizontally" })
keymap("n", "<leader>we", "<C-w>=", { desc = "Make windows equal size" })
keymap("n", "<leader>wq", "<C-w>q", { desc = "Close current window" })
keymap("n", "<leader>wx", "<C-w>x", { desc = "Swap current window with next" })

-- CODE
keymap("n", "<leader>ci", "gg=G", { desc = "Auto-indent entire file" })

keymap("n", "<leader>cf", function()
	local conform_ok, conform = pcall(require, "conform")
	if conform_ok then
		conform.format({ async = true })
	else
		vim.lsp.buf.format()
	end
end, { desc = "Format buffer (conform/LSP)" })

keymap("n", "<leader>ct", function()
	local conform_ok, conform = pcall(require, "conform")
	if conform_ok then
		local current = vim.g.disable_autoformat or false
		vim.g.disable_autoformat = not current
		print("Auto-format on save: " .. (current and "ON" or "OFF"))
	else
		print("Conform not available")
	end
end, { desc = "Toggle auto-format on save" })

-- MARKDOWN
keymap("n", "<leader>m", ":MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview" })

-- Compile.lua
local compile = require("core.compile")

vim.keymap.set("n", "<leader>cc", function()
	vim.cmd("Compile")
end, { desc = "Compilar (Compile)" })

vim.keymap.set("n", "<leader>cR", function()
	compile.reset()
end, { desc = "Reiniciar comando de compilación" })

vim.keymap.set("n", "<leader>cr", ":Run<CR>", { desc = "Compile and Run" })

-- Diagonostics
vim.keymap.set("n", "gl", function()
	local current_win = vim.api.nvim_get_current_win()
	local wininfo = vim.fn.getwininfo(current_win)[1]

	if wininfo and wininfo.loclist == 1 then
		vim.cmd("lclose")
	else
		vim.diagnostic.setloclist()

		for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.fn.getwininfo(winid)[1].loclist == 1 then
				vim.api.nvim_set_current_win(winid)
				break
			end
		end
	end
end, { desc = "Toggle, refresh and focus diagnostics in loclist" })
