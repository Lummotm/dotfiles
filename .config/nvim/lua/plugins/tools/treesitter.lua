return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPost", "BufNewFile" },
	build = ":TSUpdate",
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
				"markdown",
				"markdown_inline",
			},
			indent = {
				enable = true,
			},
		})
	end,
}
