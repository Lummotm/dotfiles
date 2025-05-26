local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Clipboard: usar siempre el portapapeles del sistema
keymap({ "n", "v" }, "y", '"+y', { desc = "Yank to system clipboard" })
keymap("n", "yy", '"+yy', { desc = "Yank line to system clipboard" })

keymap({ "n", "v" }, "x", '"+x', { desc = "Cut to system clipboard" })

keymap({ "n", "v" }, "p", '"+p', { desc = "Paste from system clipboard" })
keymap({ "n", "v" }, "P", '"+P', { desc = "Paste before from system clipboard" })

-- Delete sin guardar en yank register
keymap("n", "d", '"_d', { desc = "Delete without yanking" })
keymap("v", "d", '"_d', { desc = "Delete without yanking" })

-- Autoindent del archivo entero
keymap("n", "<leader>si", "gg=G", { desc = "Autoindent Entire File" })

-- Centrar scroll
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Extra (opcional): copiar selección visual rápida con <leader>y
keymap("v", "<leader>y", '"+y', { desc = "Yank visual to clipboard (alt)" })
keymap({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clipboard (alt)" })
keymap("n", "<leader>scs", function()
	if vim.opt.spell:get() and vim.opt.spelllang:get()[1] == "es" then
		vim.opt.spell = false
		print("Spell check: OFF")
	else
		vim.opt.spell = true
		vim.opt.spelllang = { "es" }
		print("Spell check: Spanish")
	end
end, { desc = "Toggle Spell check: Spanish" })

keymap("n", "<leader>sce", function()
	if vim.opt.spell:get() and vim.opt.spelllang:get()[1] == "en" then
		vim.opt.spell = false
		print("Spell check: OFF")
	else
		vim.opt.spell = true
		vim.opt.spelllang = { "en" }
		print("Spell check: English")
	end
end, { desc = "Toggle Spell check: English" })
