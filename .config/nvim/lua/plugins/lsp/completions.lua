---@type LazySpec
return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      "onsails/lspkind-nvim",
      "windwp/nvim-autopairs",
    },
    config = function()
      local cmp, luasnip = require("cmp"), require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      require("nvim-autopairs").setup{}
      cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())

      cmp.setup {
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        formatting = { format = require("lspkind").cmp_format({ with_text = true }) },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"]    = cmp.mapping.select_next_item(),
          ["<S-Tab>"]  = cmp.mapping.select_prev_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]    = cmp.mapping.abort(),
          ["<CR>"]     = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          { name = "nvim_lua" },
        },
      }

      -- cmdline
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },
}

