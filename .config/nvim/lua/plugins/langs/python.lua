return {
  {
    "neovim/nvim-lspconfig",
    ft = "python",
    config = function()
      require("lspconfig").pyright.setup{}
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    config = function()
      require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
    end,
  },
  {
    "psf/black",
    ft = "python",
    cmd = "Black",
  },
  {
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  },
}

