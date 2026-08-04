-- lua/core/compile.lua
local M = {}

-- Comandos por defecto según el filetype (Build vs Run)
local default_build = {
	rust = "cargo build",
	go = "go build",
	c = "make",
	cpp = "make",
	python = "python3 %",
	typescript = "npm run build",
	javascript = "node %",
	sh = "bash %",
}

local default_run = {
	rust = "cargo run",
	go = "go run .",
	c = "./main",
	cpp = "./main",
	python = "python3 %",
	typescript = "npm run build && node .",
	javascript = "node %",
	sh = "bash %",
}

-- Detección de marcadores de proyecto
local project_markers = {
	{ file = "Cargo.toml", build = "cargo build", run = "cargo run" },
	{ file = "CMakeLists.txt", build = "cmake --build build", run = "./build/main" },
	{ file = "Makefile", build = "make", run = "make run" },
	{ file = "package.json", build = "npm run build", run = "npm start" },
	{ file = "go.mod", build = "go build ./...", run = "go run ." },
}

-- Memoria por directorio (CWD -> Comando)
local project_build_cache = {}
local project_run_cache = {}

local term_buf = nil
local term_win = nil

local function get_cwd()
	return vim.fn.getcwd()
end

local function detect_project(mode)
	local cwd = get_cwd()
	for _, marker in ipairs(project_markers) do
		if vim.fn.filereadable(cwd .. "/" .. marker.file) == 1 then
			return marker[mode]
		end
	end
	return nil
end

-- Ejecución en terminal tipo buffer interactivo
local function execute_in_term(cmd)
	vim.cmd("silent! wall")
	local expanded_cmd = vim.fn.expandcmd(cmd)

	-- Reutilizar ventana de terminal si existe y es válida
	if term_win and vim.api.nvim_win_is_valid(term_win) then
		vim.api.nvim_set_current_win(term_win)
	else
		vim.cmd("botright 12new")
		term_win = vim.api.nvim_get_current_win()
	end

	-- Limpiar buffer anterior si existe
	if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
		vim.api.nvim_buf_delete(term_buf, { force = true })
	end

	term_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(term_win, term_buf)

	local shell = vim.env.SHELL or "bash"
	local chan_id = vim.fn.termopen(shell)

	vim.fn.chansend(chan_id, expanded_cmd .. "\r")

	vim.bo[term_buf].buflisted = false
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false

	vim.cmd("startinsert")
end

function M.compile(opts)
	local cwd = get_cwd()
	local ft = vim.bo.filetype
	local cmd = (opts and opts.args) or ""

	if cmd ~= "" then
		project_build_cache[cwd] = cmd
	elseif not project_build_cache[cwd] then
		project_build_cache[cwd] = detect_project("build") or default_build[ft] or "make"
	end

	execute_in_term(project_build_cache[cwd])
end

function M.run(opts)
	local cwd = get_cwd()
	local ft = vim.bo.filetype
	local cmd = (opts and opts.args) or ""

	if cmd ~= "" then
		project_run_cache[cwd] = cmd
	elseif not project_run_cache[cwd] then
		project_run_cache[cwd] = detect_project("run") or default_run[ft] or default_build[ft] or "make"
	end

	execute_in_term(project_run_cache[cwd])
end

function M.reset()
	local cwd = get_cwd()
	project_build_cache[cwd] = nil
	project_run_cache[cwd] = nil
	vim.notify("Comando de compilación/ejecución reiniciado", vim.log.levels.INFO)
end

-- Alterna o da el foco a la ventana de compilación
function M.focus()
	if term_win and vim.api.nvim_win_is_valid(term_win) then
		local current_win = vim.api.nvim_get_current_win()
		if current_win == term_win then
			-- Si ya estás dentro de la terminal, te devuelve al código
			vim.cmd("wincmd p")
		else
			-- Si estás en el código, mueve el foco a la terminal
			vim.api.nvim_set_current_win(term_win)
		end
	else
		vim.notify("No hay terminal de compilación activa", vim.log.levels.WARN)
	end
end

-- Registro de comandos
vim.api.nvim_create_user_command("Compile", M.compile, { nargs = "*" })
vim.api.nvim_create_user_command("Run", M.run, { nargs = "*" })
vim.api.nvim_create_user_command("CompileReset", M.reset, {})

return M
