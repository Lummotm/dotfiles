return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "tex" },
            },
            auto_install = true,
            ensure_installed = {
                "lua",
                "latex",
                "c",
                "cpp",
                "python",
                "bash",
                "regex",
                "vim",
                "vimdoc",
                "markdown",
                "markdown_inline",
                "query",
                "matlab",
            },
            indent = {
                enable = true,
                disable = { "python", "yaml" },
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        })

        -- Forzar detección automática al abrir cualquier archivo
        vim.api.nvim_create_autocmd({ "BufReadPost" }, {
            callback = function()
                vim.schedule(function()
                    if vim.bo.filetype == "" then
                        -- si el tipo esta vacio ejecutar la función para sacar el tipo
                        vim.cmd("filetype detect")
                        print("Forzando filetype detect para: " .. vim.fn.expand("%:t"))
                    end
                end)
            end,
        })

        -- Asegurar que el highlighting esté habilitado
        vim.cmd([[
            if exists('+termguicolors')
                set termguicolors
            endif
        ]])
    end,
}
