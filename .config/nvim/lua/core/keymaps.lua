local keymap = vim.keymap.set

--  Clipboard Integration
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus" -- Use system clipboard

	-- Use black hole register for 'd' (delete doesn't copy)
	vim.keymap.set("n", "d", '"_d', { noremap = true, desc = "Delete without yanking" })
	vim.keymap.set("v", "d", '"_d', { noremap = true, desc = "Delete without yanking" })
end)

--  Style / Formatting
keymap("n", "<leader>si", "magg=G`a", { desc = "Autoindent Entire File" })

keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

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
