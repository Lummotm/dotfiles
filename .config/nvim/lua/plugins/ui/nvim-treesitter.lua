return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = { enable = true },
				auto_install = true,
        -- cuando se encuentra con un tipo de archivo que no conoce lo instala
				additional_vim_regex_highlighting = false,
			})
		end,
	},
}
