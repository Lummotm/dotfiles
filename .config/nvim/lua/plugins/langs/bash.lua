return {
  {
    "williamboman/mason-lspconfig.nvim",
  },
  {
    "neovim/nvim-lspconfig",
    ft = { "sh", "bash" },
    config = function()
      require("lspconfig").bashls.setup{}
    end,
  },
}

