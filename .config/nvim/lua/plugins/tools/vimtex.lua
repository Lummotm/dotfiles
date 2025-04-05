return {
	"lervag/vimtex",
	lazy = false,
	init = function()
		-- Desactivar el módulo de sintaxis de vimtex (usamos Treesitter)
		vim.g.vimtex_syntax_enabled = 0

		-- Configurar el compilador
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_compiler_latexmk = {
			build_dir = "build", -- Directorio para archivos auxiliares
			continuous = 1, -- Compilación continua (1 para activar)
			options = {
				"-verbose",
				"-file-line-error",
				"-synctex=1",
				"-interaction=nonstopmode",
				"-outdir=build",
			},
		}

		-- Desactivar quickfix integrado (usaremos vimux)
		vim.g.vimtex_quickfix_mode = 0

		-- Viewer (opcional)
		vim.g.vimtex_view_method = "zathura"
	end,
	config = function()
		-- Sobrescribir el comando :VimtexCompile para usar Vimux
		vim.cmd([[
      function! s:compile_with_vimux() abort
        let l:cmd = 'latexmk -pdf -interaction=nonstopmode -outdir=build % && latexmk -c -outdir=build %'
        call VimuxRunCommand(l:cmd)
      endfunction

      command! VimtexCompile call s:compile_with_vimux()
    ]])
	end,
}

