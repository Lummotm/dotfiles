return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",  -- Versión estable
    dependencies = {
      "nvim-lua/plenary.nvim",  -- Obligatorio
      "nvim-treesitter/nvim-treesitter",  -- Opcional (mejora resaltado)
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        find_files = {
          theme = "dropdown",  -- Interfaz con menú desplegable
          hidden = true,       -- Incluye archivos ocultos (ej: .gitignore)
        },
      })
    end,
  },
}
