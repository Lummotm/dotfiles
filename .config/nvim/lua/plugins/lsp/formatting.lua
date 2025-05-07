---@type LazySpec
return {
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    config = function()
      require("null-ls").setup {
        sources = {
          require("null-ls").builtins.formatting.stylua,
          require("null-ls").builtins.formatting.black,
          require("null-ls").builtins.formatting.isort,
        },
      }
    end,
  },
}

