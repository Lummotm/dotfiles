return {
  -- ===== PYTHON =====
  {
    "neovim/nvim-lspconfig",
    ft = "python",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "strict",
                autoSearchPaths = true
              }
            }
          }
        }
      }
    }
  },
}
