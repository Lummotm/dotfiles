return {
  "oncomouse/lushwal.nvim",
  cmd = { "LushwalCompile" },
  lazy = false,
  dependencies = {
    { "rktjmp/lush.nvim" },
    { "rktjmp/shipwright.nvim" }
  },
  config = function()
    vim.g.lushwal_configuration = {
      transparent_background = true,
      compile_to_vimscript = false,
      terminal_colors = true,
      wal_path = vim.fn.expand("$HOME/.cache/wal/colors.json"),
      addons = {
        native_lsp = true,
        treesitter = true,
        lualine = true,
        telescope_nvim = true,
        nvim_cmp = true,
      }
    }

    vim.cmd [[LushwalCompile]]
  end,
}
