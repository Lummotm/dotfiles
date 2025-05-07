return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_syntax_enabled = 0
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_quickfix_ignore_filters = {  -- Ignora estos warnings
      "Underfull",
      "Overfull",
      "specifier changed to",
    }
    vim.g.vimtex_compiler_latexmk = {
      continuous = 1,
      options = {
        "-shell-escape",
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      }
    }
    vim.g.vimtex_matchparen_enabled = 0
  end
}
