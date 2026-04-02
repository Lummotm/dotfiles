-- molten is a plugin to interact with jupyter kernel
-- to optimize the workflow from sage with nvim
return {
	{
		"benlubas/molten-nvim",
		enabled = false,
		version = "^1.0.0",
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_use_border_highlights = true
			vim.g.molten_virt_text_output = false
			vim.g.molten_auto_open_output = true
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_lines_off_by_1 = true
			vim.g.molten_output_show_executable = true
		end,
	},
	{
		"3rd/image.nvim",
		enabled = false,
		opts = {
			backend = "kitty",
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
	},
}
