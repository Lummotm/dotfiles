return {
  {
    'lervag/vimtex',
    ft = 'tex',
    init = function()
      -- Desactivar resaltado sintáctico integrado
      vim.g.vimtex_syntax_enabled = 0
      
      -- Configurar latexmk con limpieza mejorada
      vim.g.vimtex_compiler_method = 'latexmk'
      vim.g.vimtex_compiler_latexmk = {
        options = {
          '-verbose',
          '-file-line-error',
          '-synctex=1',
          '-interaction=nonstopmode',
          '-pdf',
        },
        build_dir = 'out',  -- Directorio para archivos de compilación
      }

      -- Limpieza mejorada al salir de Neovim
      vim.api.nvim_create_autocmd('VimLeave', {
        pattern = '*.tex',
        callback = function()
          -- Comando principal de latexmk para limpiar
          vim.fn.system('latexmk -c -silent ' .. vim.fn.shellescape(vim.fn.expand('%')))
          
          -- Eliminar archivos adicionales específicos
          local base = vim.fn.expand('%:r')
          local extras = {
            '.nav', '.snm', '.vrb', '.bbl', 
            '.fls', '.fdb_latexmk', '.synctex.gz'
          }
          
          for _, ext in ipairs(extras) do
            local file = base .. ext
            if vim.fn.filereadable(file) == 1 then
              os.remove(file)
            end
          end
          
          -- Limpiar directorio de compilación si existe
          if vim.fn.isdirectory('out') == 1 then
            vim.fn.delete('out', 'rf')
          end
        end
      })
      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = '*.tex',
        callback = function()
          vim.cmd('silent! VimtexCompile')  -- Compila al guardar, pero no entra en modo continuo
        end,
      })
    end
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "iurimateus/luasnip-latex-snippets.nvim" },
    config = function()
      require("luasnip").config.setup({ enable_autosnippets = true })
      require("luasnip-latex-snippets").setup()
    end,
    ft = "tex", -- Se carga solo en archivos LaTeX
  }
}
