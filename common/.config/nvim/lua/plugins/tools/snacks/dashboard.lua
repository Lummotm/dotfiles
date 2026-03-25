return {
	enabled = false,
	sections = {
		{ section = "header" },
		{ section = "keys", gap = 1, padding = 1 },
		{ section = "startup" },
	},
	preset = {
		header = [[
=================     ===============     ===============   ========  ========
||. . . . . . .\\   //. . . . . . .\\   //. . . . . . .\\  \\. . .\\// . .  ||
||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . .||
|| . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||
||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||
|| . .||   ||. *-|| ||-* .||   ||. . || || . .||   ||. *-|| ||-*.|\ . . . . ||
||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\_ . .|. .||
|| . *||   ||    || ||    ||   ||* . || || . *||   ||    || ||   |\ `-*/| . ||
||_-' ||  .|/    || ||    \|.  || `-_|| ||_-' ||  .|/    || ||   | \  / |-_.||
||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \  / |  `||
||    `'         || ||         `'    || ||    `'         || ||   | \  / |   ||
||            .===' `===.         .==='.`===.         .===' /==. |  \/  |   ||
||           .=='   \_|-_ `===. .==='   |   `===. .===' _-|/   `==  \/  |   ||
||      .=='    *-'    *`-  `='    *-'   *`-    `='  *-'   `-*  /|  \/  |   ||
||   .=='    *-'          '-*_\._-'         '-_./__-'         `' |. /|  |   ||
||.=='    _-'                                                     `' |  /==.||
=='    _-'                        N E O V I M                         \/   `==
\   *-'                                                                `-*   /
 `''                                                                      ``'
]],
		keys = {
			{ icon = "󰎔", key = "n", desc = "New file", action = ":enew" },
			{ icon = "󰉋", key = "e", desc = "File Explorer", action = ":Yazi" },
			{
				icon = "󰈞",
				key = "f",
				desc = "Find Files",
				action = function()
					require("snacks").picker.files({
						follow = true,
					})
				end,
			},
			{
				icon = "󰥔",
				key = "g",
				desc = "Grep Files",
				action = function()
					require("snacks").picker.grep({
						cmd = "rg",
						hidden = false,
						ignored = false,
						follow = true,
					})
				end,
			},
			{
				icon = "󰋚",
				key = "r",
				desc = "Recent Files",
				action = function()
					require("snacks").picker.recent()
				end,
			},
			{ icon = "󰗖", key = "L", desc = "Lazy plugins", action = ":Lazy" },
			{ icon = "󰿅", key = "q", desc = "Quit", action = ":q" },
		},
	},
}
