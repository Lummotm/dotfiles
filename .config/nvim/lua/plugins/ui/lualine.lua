return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "arkav/lualine-lsp-progress" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { "alpha", "dashboard", "neo-tree" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename", "lsp_progress" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
