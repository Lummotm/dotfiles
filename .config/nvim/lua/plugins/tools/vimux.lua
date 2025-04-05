return {
  "preservim/vimux",
  lazy = false, -- Cargar inmediatamente
  config = function()
    -- Configuración básica de Vimux (opcional)
    vim.g.VimuxHeight = "5"   -- Altura del panel de tmux (en %)
    vim.g.VimuxOrientation = "v" -- Orientación: "v" (vertical) u "h" (horizontal)
  end,
}
