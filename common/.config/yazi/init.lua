-- Plugin setup
require("full-border"):setup()

require("augment-command"):setup({
	prompt = false,
	default_item_group_for_prompt = "hovered",
	smart_enter = true,
	smart_paste = false,
	smart_tab_create = false,
	smart_tab_switch = false,
	confirm_on_quit = true,
	open_file_after_creation = true,
	enter_directory_after_creation = false,
	use_default_create_behaviour = false,
	enter_archives = true,
	extract_retries = 3,
	recursively_extract_archives = true,
	preserve_file_permissions = false,
	encrypt_archives = false,
	encrypt_archive_headers = false,
	reveal_created_archive = true,
	remove_archived_files = false,
	must_have_hovered_item = true,
	skip_single_subdirectory_on_enter = true,
	skip_single_subdirectory_on_leave = true,
	smooth_scrolling = false,
	scroll_delay = 0.02,
	create_item_delay = 0.25,
	wraparound_file_navigation = true,
})

-- require("yatline"):setup({
-- 	show_background = false,
--
-- 	header_line = {
-- 		left = {
-- 			section_a = {
-- 				{ type = "line", custom = false, name = "tabs", params = { "left" } },
-- 			},
-- 			section_b = {},
-- 			section_c = {},
-- 		},
-- 		right = {
-- 			section_a = {
-- 				{ type = "string", custom = false, name = "date", params = { "%a, %d %B %Y" } },
-- 			},
-- 			section_b = {},
-- 			section_c = {},
-- 		},
-- 	},
--
-- 	status_line = {
-- 		left = {
-- 			section_a = {
-- 				{ type = "string", custom = false, name = "tab_mode" },
-- 			},
-- 			section_b = {
-- 				{ type = "string", custom = false, name = "hovered_size" },
-- 			},
-- 			section_c = {
-- 				{ type = "string", custom = false, name = "hovered_path" },
-- 				{ type = "coloreds", custom = false, name = "count" },
-- 			},
-- 		},
-- 		right = {
-- 			section_a = {
-- 				{ type = "string", custom = false, name = "cursor_position" },
-- 			},
-- 			section_b = {
-- 				{ type = "string", custom = false, name = "cursor_percentage" },
-- 			},
-- 			section_c = {
-- 				{ type = "string", custom = false, name = "hovered_file_extension", params = { true } },
-- 				{ type = "coloreds", custom = false, name = "permissions" },
-- 			},
-- 		},
-- 	},
-- })
