return {
    {
        "mstanciu552/tree-sitter-matlab",
        ft = "matlab",
        build = ":TSInstall matlab",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
    "L3MON4D3/LuaSnip",
    ft = "matlab",
    config = function()
        local ls = require("luasnip")

        -- Snippets personalizados
        ls.add_snippets("matlab", {
            -- For loop snippet
            ls.parser.parse_snippet({
                trig = "for",
                name = "For loop",
                dscr = "For con end automático"
            }, "for ${1:i} = ${2:1}:${3:n}\n\t${4:code}\nend"),

            -- If statement snippet
            ls.parser.parse_snippet({
                trig = "if",
                name = "If statement",
                dscr = "If con end automático"
            }, "if ${1:condición}\n\t${2:code}\nend"),

            -- While loop snippet
            ls.parser.parse_snippet({
                trig = "while",
                name = "While loop",
                dscr = "While con end automático"
            }, "while ${1:condición}\n\t${2:code}\nend"),

            -- Switch case snippet
            ls.parser.parse_snippet({
                trig = "switch",
                name = "Switch case",
                dscr = "Switch con case y end automático"
            }, "switch ${1:variable}\n\tcase ${2:value}\n\t\t${3:code}\n\tcase ${4:default}\n\t\t${5:default_code}\nendswitch"),

            -- Function definition snippet
            ls.parser.parse_snippet({
                trig = "func",
                name = "Function definition",
                dscr = "Definición de función"
            }, "function ${1:output} = ${2:function_name}(${3:input})\n\t${4:code}\nend"),
          })
      end
    },
    {
        "hrsh7th/nvim-cmp",
        ft = "matlab",
        opts = {
            sources = {
                { name = "buffer" },
                { name = "luasnip" },
                { name = "path" }
            }
        }
    }
}
