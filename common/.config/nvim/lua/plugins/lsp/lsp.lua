-- LSP configuration: Language Server Protocol setup
-- LSP provides language-specific features: completions, diagnostics, go-to-definition, etc.

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "saghen/blink.cmp" },

	-- LSP keybindings: Basic navigation and refactoring
	keys = {
		{ "<leader>ca", vim.lsp.buf.code_action, desc = "Code actions" },
		{ "K", vim.lsp.buf.hover, desc = "Hover docs", mode = "n" },
		-- { "gd", vim.lsp.buf.definition, desc = "Go to definition" },
		-- { "gr", vim.lsp.buf.references, desc = "Show references" },
		-- { "<leader>cr", vim.lsp.buf.rename, desc = "Rename symbol" },
		{ "gl", vim.diagnostic.setloclist, desc = "Open diagnostics in loclist buffer" },
		{ "[d", vim.diagnostic.goto_prev, desc = "Previous diagnostic" },
		{ "]d", vim.diagnostic.goto_next, desc = "Next diagnostic" },
	},

	config = function()
		-- Get LSP capabilities from Blink.cmp for enhanced completion
		local capabilities = require("blink.cmp").get_lsp_capabilities()
		vim.diagnostic.config({
			signs = true, -- Show icons in sign column
			underline = true, -- Underline error locations
			virtual_text = true, -- Inline error messages
			update_in_insert = true, -- Update while typing
			severity_sort = true, -- Sort by severity

			-- Configuración específica para los diagnósticos en ventana flotante
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
				wrap = true,
				max_width = 80, -- Limita el ancho para que la ventana crezca hacia abajo
			},
		})
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "vimdiagnostic",
			callback = function(args)
				-- Forzar wrap a nivel de ventana y de buffer
				vim.wo[0][0].wrap = true
				vim.bo[args.buf].textwidth = 0
			end,
		})

		-- LSP servers: Each server provides language-specific features
		local servers = {
			-- Lua: Neovim config development
			lua_ls = { capabilities = capabilities },

			-- C/C++: C language development
			clangd = { capabilities = capabilities },

			-- Python: Type checking and completions
			basedpyright = {
				capabilities = capabilities,
				settings = {
					basedpyright = {
						analysis = {
							-- Only analyze open files (less CPU, faster)
							diagnosticMode = "openFilesOnly",
							typeCheckingMode = "basic",
							-- Silence noisy diagnostics
							diagnosticSeverityOverrides = {
								reportUnusedCallResult = "none",
								reportUnknownParameterType = "none",
								reportUnknownArgumentType = "none",
								reportUnknownLambdaType = "none",
								reportUnknownVariableType = "none",
								reportUnknownMemberType = "none",
								reportMissingTypeArgument = "none",
								reportAny = "none",
							},
						},
					},
				},
			},

			-- Bash: Shell script support
			bashls = { capabilities = capabilities },

			-- Typst: Typst markup language (LaTeX alternative)
			tinymist = {
				capabilities = capabilities,
				settings = {
					formatterMode = "typstyle",
					exportPdf = "onType",
					outputPath = "/$name",
					semanticTokens = "disable",
				},
			},

			-- LaTeX: Build and forward search with Zathura
			texlab = {
				capabilities = capabilities,
				settings = {
					texlab = {
						build = {
							args = { "-pdf", "-interaction=nonstopmode", "-synctex=1" },
							onSave = false,
						},
						forwardSearch = {
							executable = "zathura",
							args = { "--synctex-forward", "%l:1:%f", "%p" },
						},
					},
				},
			},

			-- MATLAB: MATLAB language server
			matlab_ls = {
				capabilities = capabilities,
				settings = {
					MATLAB = {
						indexWorkspace = true,
						installPath = "/home/davidn/.local/MATLAB/R2025b/",
						matlabConnectionTiming = "onStart",
						telemetry = false,
					},
				},
			},

			-- QML / Quickshell language server
			qmlls = {
				cmd = { "qml-language-server" },
				capabilities = capabilities,
				root_markers = { { "qmldir", "shell.qml" }, ".git" },
			},

			-- Rust: Rust development with clippy
			rust_analyzer = {
				capabilities = capabilities,
				settings = {
					["rust-analyzer"] = {
						checkOnSave = { command = "clippy" },
						procMacro = { enable = true },
						cargo = { allFeatures = false },
						-- Añade esto:
						completion = {
							privateEditable = { enable = false },
							fullFunctionSignatures = { enable = false },
							postfix = { enable = false },
						},
					},
				},
			},
			obsidian_ls = { capabilities = capabilities },
		}

		-- Register all servers with Neovim's LSP client
		for server_name, config in pairs(servers) do
			vim.lsp.config(server_name, config)
			vim.lsp.enable(server_name)
		end
	end,
}
