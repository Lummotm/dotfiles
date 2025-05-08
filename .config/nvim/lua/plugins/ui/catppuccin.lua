return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,

  config = function()
    require("catppuccin").setup({
      flavor = "mocha",
      transparent_background = true,
      term_colors = true,

      integrations = {
        cmp = true,
        treesitter = true,
        snacks = {
          enabled = false,
          indent_scope_color = "", -- catppuccin color (eg. `lavender`) Default: text
        },
        which_key = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
        noice = true,
        mason = true,
      }
    })
  end
}
