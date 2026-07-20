-- Autopairs: Automatically close brackets and quotes
return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	dependencies = { "blink.cmp" },
	config = function()
		require("nvim-autopairs").setup({ check_ts = true })
	end,
}
