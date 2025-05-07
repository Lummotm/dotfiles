return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    window = {
      width = 25,
      position = "left",
    },
  },
  keys = {
    { "<C-n>", "<cmd>Neotree toggle left<CR>", desc = "Toggle Neo-tree" },
  },
}
