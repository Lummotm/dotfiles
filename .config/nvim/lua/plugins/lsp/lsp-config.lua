---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local caps = require("cmp_nvim_lsp").default_capabilities()

      for _, srv in ipairs({ "pyright", "clangd", "bashls", "texlab" }) do
        lspconfig[srv].setup {
          capabilities = caps,
        }
      end

      -- Config global de diagnósticos
      vim.diagnostic.config {
        virtual_text = { prefix = "■ ", source = "if_many" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      }
    end,
  },
}

