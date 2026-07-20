-- Folds: Advanced folding with UFO and LSP support
return {
	"kevinhwang91/nvim-ufo",
	dependencies = "kevinhwang91/promise-async",
	event = "BufReadPost",
	init = function()
		vim.o.foldcolumn = "0"
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true
	end,
	config = function()
		require("ufo").setup({
			provider_selector = function(bufnr, filetype, buftype)
				if filetype == "markdown" then
					return { "treesitter", "indent" }
				end
				return { "lsp", "indent" }
			end,
		})
		vim.keymap.set("n", "zR", require("ufo").openAllFolds)
		vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
		vim.api.nvim_create_autocmd("BufReadPost", {
			callback = function()
				vim.defer_fn(function() require("ufo").openAllFolds() end, 100)
			end,
		})
	end,
}
