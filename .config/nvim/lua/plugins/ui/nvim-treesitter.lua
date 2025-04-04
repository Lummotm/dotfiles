return{
  {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "c", "cpp", "python", "latex", "matlab" },
          highlight = { enable = true },
        })
      end,
  },
}
