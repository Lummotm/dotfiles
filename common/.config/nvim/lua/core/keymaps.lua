local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Copy and paste from clipboard
keymap({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
keymap("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
keymap({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

-- Center scroll
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Quit keymap
keymap("n", "<leader>q", ":q!<CR>", { desc = "Exit" })

-- Toggle between spellcheck (ES/EN/OFF)
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

-- BUFFER
keymap("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
keymap("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>ba", ':%bdelete|edit #|normal `"<CR>', { desc = "Delete all except current" })
keymap("n", "<leader>bD", ":bdelete!<CR>", { desc = "Force delete buffer" })
keymap("n", "<leader>bw", ":w!<CR>", { desc = "BufferWrite" })

-- CODE ACTIONS UNIFIED
-- Auto-indent entire file
keymap("n", "<leader>ci", "gg=G", { desc = "Auto-indent entire file" })

-- Format buffer
keymap("n", "<leader>cf", function()
	-- Primero intentar con conform si está disponible
	local conform_ok, conform = pcall(require, "conform")
	if conform_ok then
		conform.format({ async = true })
	else
		-- Fallback a LSP formatting
		vim.lsp.buf.format()
	end
end, { desc = "Format buffer (conform/LSP)" })

-- Toggle auto-format on save
keymap("n", "<leader>ct", function()
	-- Toggle global format on save (si usas conform)
	local conform_ok, conform = pcall(require, "conform")
	if conform_ok then
		local current = vim.g.disable_autoformat or false
		vim.g.disable_autoformat = not current
		print("Auto-format on save: " .. (current and "ON" or "OFF"))
	else
		print("Conform not available")
	end
end, { desc = "Toggle auto-format on save" })

-- SAGE / MOLTEN (Optimizado)
-- Gestión del Kernel
-- keymap("n", "<leader>mi", ":MoltenInit sagemath<CR>", { desc = "Sage: Init Kernel" })
--
-- -- Ejecución de Código
-- keymap("n", "<leader>me", ":MoltenEvaluateOperator<CR>", { desc = "Sage: Run operator" })
-- keymap("n", "<leader>ml", ":MoltenEvaluateLine<CR>", { desc = "Sage: Eval line" })
-- keymap("n", "<leader>mr", ":MoltenReevaluateCell<CR>", { desc = "Sage: Re-eval cell" })
-- keymap("v", "<leader>me", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Sage: Eval selection" })
-- keymap("n", "<leader>ma", "mzggVG:<C-u>MoltenEvaluateVisual<CR>`z", { desc = "Sage: Eval all file" })
--
-- -- Ventana de Output (Resultados)
-- keymap("n", "<leader>mo", ":MoltenEnterOutput<CR>", { desc = "Sage: Open/Enter output" })
-- keymap("n", "<leader>mh", ":MoltenHideOutput<CR>", { desc = "Sage: Hide output" })
-- keymap("n", "<leader>md", ":MoltenDelete<CR>", { desc = "Sage: Delete cell" })
--
-- -- Navegación entre celdas (Resultados previos/siguientes)
-- keymap("n", "<leader>mj", ":MoltenNext<CR>", { desc = "Sage: Next cell" })
-- keymap("n", "<leader>mk", ":MoltenPrev<CR>", { desc = "Sage: Prev cell" })
