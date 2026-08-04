local config_dir = os.getenv("HOME") .. "/.config/yazi"
local plugins_dir = config_dir .. "/plugins"

-- Plugins list
-- repo: the one thats on "ya pkg add {repo}"
local plugins = {
	{ repo = "yazi-rs/plugins:full-border" },
	{ repo = "Sonico98/exifaudio" },
}

local dir_exists = os.rename(plugins_dir, plugins_dir)

if not dir_exists then
	os.remove("package.toml")
end

for _, plugin in ipairs(plugins) do
	-- Clean name
	local raw_name = plugin.name or plugin.repo:match(":(.+)$") or plugin.repo:match("/([^/]+)$")
	local mod_name = raw_name:gsub("%.yazi$", "") -- "exifaudio.yazi" -> "exifaudio"

	local plugin_folder = plugins_dir .. "/" .. mod_name .. ".yazi"
	local entry_file = plugin_folder .. "/main.lua"

	-- Install if it doesnt exists
	local check_file = io.open(entry_file, "r")
	if not check_file then
		os.execute("ya pkg add " .. plugin.repo)
	else
		check_file:close()
	end

	-- Load pluign when added
	local ok, err = pcall(function()
		local mod = require(mod_name)
		if type(mod) == "table" and type(mod.setup) == "function" then
			mod:setup()
		end
	end)

	-- Register errors on fail
	if not ok then
		local log_file = io.open(config_dir .. "/error_" .. mod_name .. ".txt", "w")
		if log_file then
			log_file:write("--- Error cargando " .. mod_name .. " ---\n" .. tostring(err) .. "\n")
			log_file:close()
		end
	end
end
