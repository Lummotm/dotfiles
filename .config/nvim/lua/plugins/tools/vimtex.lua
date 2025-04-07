return {
	"lervag/vimtex",
	lazy = false,
	init = function()
		-- Desactivar el módulo de sintaxis de vimtex (usamos Treesitter)
		vim.g.vimtex_syntax_enabled = 0

		-- Configurar el compilador
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_compiler_latexmk = {
			continuous = 1, -- Compilación continua (1 para activar)
		}
    vim.g.vimtex_quickfix_open_on_warning = 0
	end,
}
