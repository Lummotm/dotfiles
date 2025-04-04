return{
  {
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "latex", "matlab", "c" },
        highlight = { enable = true },
        auto_install = true,
        additional_vim_regex_highlighting = false,
      })
    end,
  },
}
