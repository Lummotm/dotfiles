return {
	"lervag/vimtex",
	lazy = false,
	init = function()
		-- Desactivar el módulo de sintaxis de vimtex (usa Treesitter)
		vim.g.vimtex_syntax_enabled = 0

		-- Configurar el compilador
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_compiler_latexmk = {
			build_dir = "build", -- Directorio para archivos auxiliares
			continuous = 1, -- Compilación continua (1 para activar)
		}

		-- Desactivar quickfix integrado (usaremos vimux)
		vim.g.vimtex_quickfix_mode = 0

		-- Viewer (opcional)
		vim.g.vimtex_view_method = "zathura"

		-- Atajo personalizado para compilar con vimux
		vim.api.nvim_set_keymap("n", "<leader>ll", ":VimtexCompile<CR>", { noremap = true, silent = true })
	end,
	config = function()
		-- Sobrescribir el comando :VimtexCompile para usar vimux
		vim.cmd([[
    function! s:compile_with_vimux() abort
    let l:cmd = 'latexmk -pdf -interaction=nonstopmode %'
    call VimuxRunCommand(l:cmd)
    endfunction

    command! VimtexCompile call s:compile_with_vimux()
    ]])
	end,
}
