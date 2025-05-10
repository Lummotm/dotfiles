return {
  {
    "neovim/nvim-lspconfig",
    ft = { "c", "cpp", "objc", "objcpp" },
    config = function()
      require("lspconfig").clangd.setup {}
    end,
  },
  {
    "rhysd/vim-clang-format",
    ft = { "c", "cpp" },
    cmd = "ClangFormat",
  },
}
