local config_dir = "/home/davidn/.config/yazi"
local plugins_dir = config_dir .. "/plugins"
local package_toml = config_dir .. "/package.toml"

-- Lista de plugins: nombre y repo para instalar
local plugins = {
	{ name = "full-border", repo = "yazi-rs/plugins:full-border" },
	-- { name = "otro-plugin", repo = "usuario/repo:otro-plugin" },
}

for _, plugin in ipairs(plugins) do
	local plugin_path = plugins_dir .. "/" .. plugin.name .. ".yazi/main.lua"

	-- Instala el plugin si no existe
	if not io.open(plugin_path, "r") then
		os.execute("mkdir -p " .. plugins_dir)
		os.execute("rm -f " .. package_toml)
		os.execute("ya pkg add " .. plugin.repo)
	end

	-- Carga el plugin, registrando el error si algo falla
	local ok, err = pcall(function()
		require(plugin.name):setup()
	end)

	if not ok then
		local log_file = io.open(config_dir .. "/error_" .. plugin.name .. ".txt", "w")
		if log_file then
			log_file:write("--- Error cargando " .. plugin.name .. " ---\n" .. tostring(err) .. "\n")
			log_file:close()
		end
	end
end
