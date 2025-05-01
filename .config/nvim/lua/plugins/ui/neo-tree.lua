return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- Opcional: Quita si no quieres íconos
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- Reducir el ancho de la ventana
    window = {
      width = 25, -- Ancho más estrecho (por defecto suele ser 40)
      position = "left",
    },
  },
}
