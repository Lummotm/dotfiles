return {
	-- none-ls es un fork de null-ls hecho por la comunidad, por ello los nombres de la funciones
	-- no están cambiados ni nada.
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.isort,
			},
		})
	end,
}
