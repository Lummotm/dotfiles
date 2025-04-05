return {
  "folke/noice.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  config = function()
    require("noice").setup({
      cmdline = {
        enabled = true,
        view = "cmdline_popup", -- Vista flotante para comandos
        position = {
        },
      },
      messages = {
        enabled = true,
        view = "notify", -- Mensajes como notificaciones flotantes
      },
    })
  end,
}
