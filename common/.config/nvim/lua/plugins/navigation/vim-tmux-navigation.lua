return {
	"christoomey/vim-tmux-navigator",
	lazy = true,
	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
		"TmuxNavigatorProcessList",
	},
	keys = {
		{ "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Tmux Left" },
		{ "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Tmux Down" },
		{ "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Tmux Up" },
		{ "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Tmux Right" },
		{ "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Tmux Previous" },
	},
}
