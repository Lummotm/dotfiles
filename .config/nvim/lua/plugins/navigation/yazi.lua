return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>c", name = "+Yazi" },
    { "<leader>cf", "<cmd>Yazi<CR>",       desc = "Yazi: open current file" },
    { "<leader>cw", "<cmd>Yazi cwd<CR>",   desc = "Yazi: open current directory" },
  },
  ---@type YaziConfig

  init = function()
    vim.g.loaded_netrwPlugin = 1
  end,
}

