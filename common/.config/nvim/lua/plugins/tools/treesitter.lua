-- Treesitter: Syntax highlighting and text objects
return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
	config = function()
		require("nvim-treesitter.configs").setup({
			highlight = { enable = true, additional_vim_regex_highlighting = { "tex" } },
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
			indent = { enable = true },
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

		vim.api.nvim_create_autocmd({ "BufReadPost" }, {
			callback = function()
				vim.schedule(function()
					if vim.bo.filetype == "" then
						vim.cmd("filetype detect")
					end
				end)
			end,
		})
	end,
}
