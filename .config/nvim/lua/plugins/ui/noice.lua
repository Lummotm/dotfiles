return {
  "folke/noice.nvim",
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    messages  = { enabled = false },  -- Snacks.notifier toma el relevo
    notify    = { enabled = false },
    popupmenu = { enabled = false },
    lsp       = { progress = { enabled = false }, signature = { enabled = false } },
    markdown  = { hover = { enabled = false } },
  },
}

