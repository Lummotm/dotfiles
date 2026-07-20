-- Dashboard: Startup screen with quick actions
return {
	enabled = true,
	sections = { { section = "header" }, { section = "keys", gap = 1, padding = 1 }, { section = "startup" } },
	preset = {
		keys = {
			{ icon = "󰎔", key = "n", desc = "New file", action = ":enew" },
			{ icon = "󰉋", key = "e", desc = "File Explorer", action = ":Yazi" },
			{ icon = "󰈞", key = "f", desc = "Find Files", action = function() require("snacks").picker.files({ follow = true }) end },
			{ icon = "󰥔", key = "g", desc = "Grep Files", action = function() require("snacks").picker.grep({ cmd = "rg", hidden = false, ignored = false, follow = true }) end },
			{ icon = "󰛔", key = "z", desc = "Move With Zoxide", action = function() require("snacks").picker.zoxide({}) end },
			{ icon = "󰗖", key = "L", desc = "Lazy plugins", action = ":Lazy" },
			{ icon = "󰿅", key = "q", desc = "Quit", action = ":q" },
		},
	},
}
