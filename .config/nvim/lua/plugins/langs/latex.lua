return {
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_syntax_enabled = 0
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_quickfix_ignore_filters = {
        "Underfull",
        "Overfull",
        "specifier changed to",
      }

      vim.g.vimtex_compiler_latexmk = {
        continuous = 1,
        options = {
          "-pdf", -- 👈  produce PDF (por defecto en vimtex)
          "-shell-escape",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        }
      }

      vim.g.vimtex_matchparen_enabled = 0
    end
  },
  {
    "neovim/nvim-lspconfig",
    ft = "tex",
    config = function()
      require("lspconfig").texlab.setup {
        settings = {
          texlab = {
            diagnostics = {
              ignoredPatterns = { "Underfull", "Overfull" },
            },
          },
        },
      }
    end,
  },
}
