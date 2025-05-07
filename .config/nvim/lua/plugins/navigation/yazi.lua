---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  dependencies = { "folke/snacks.nvim" },

  keys = {
    { "<leader>c", name = "+Yazi" },
    { "<leader>cf", "<cmd>Yazi<CR>",       desc = "Yazi: abrir archivo actual" },
    { "<leader>cw", "<cmd>Yazi cwd<CR>",   desc = "Yazi: abrir cwd de nvim" },
    { "<leader>cr", "<cmd>Yazi toggle<CR>",desc = "Yazi: reanudar sesión" },
  },
  ---@type YaziConfig

  init = function()
    vim.g.loaded_netrwPlugin = 1
  end,
}

