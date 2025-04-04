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
        defaults = {
          mappings = {
            i = {
              -- Atajos en modo inserción (opcional)
              ["<C-k>"] = "move_selection_previous",  -- Ctrl+k sube en la lista
              ["<C-j>"] = "move_selection_next",     -- Ctrl+j baja en la lista
            },
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",  -- Interfaz con menú desplegable
            hidden = true,       -- Incluye archivos ocultos (ej: .gitignore)
          },
        },
      })

      -- Atajos globales (opcional, o ponlos en core/keymaps.lua)
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep (texto)" })
    end,
  },
}
