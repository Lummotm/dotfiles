-- LSP: nvim-lspconfig solo aporta las configs por defecto (cmd, filetypes, root).
-- El registro y activación se hace con la API nativa de Neovim 0.11+.

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "saghen/blink.cmp" },

	config = function()
		vim.diagnostic.config({
			virtual_text = true,
			severity_sort = true,
			update_in_insert = false,
			float = {
				border = "rounded",
				source = true,
				focusable = false,
				style = "minimal",
				max_width = 80,
			},
		})

		-- Capabilities de blink para todos los servidores
		vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

		-- Solo lo que cambia respecto a los defaults de lspconfig
		local servers = {
			lua_ls = {},
			clangd = {},
			bashls = {},

			basedpyright = {
				settings = {
					basedpyright = {
						analysis = {
							diagnosticMode = "openFilesOnly",
							typeCheckingMode = "basic",
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

			tinymist = {
				settings = {
					formatterMode = "typstyle",
					exportPdf = "onType",
					outputPath = "/$name",
					semanticTokens = "disable",
				},
			},

			texlab = {
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

			matlab_ls = {
				settings = {
					MATLAB = {
						indexWorkspace = true,
						installPath = "/home/davidn/.local/MATLAB/R2025b/",
						matlabConnectionTiming = "onStart",
						telemetry = false,
					},
				},
			},

			qmlls = {
				cmd = { "qml-language-server" },
				root_markers = { { "qmldir", "shell.qml" }, ".git" },
			},

			rust_analyzer = {
				settings = {
					["rust-analyzer"] = {
						check = { command = "clippy" },
						procMacro = { enable = true },
						cargo = {
							allFeatures = false,
							buildScripts = { enable = false },
						},
						workspace = {
							symbol = { search = { scope = "workspace_and_dependencies" } },
						},
						completion = {
							privateEditable = { enable = false },
							fullFunctionSignatures = { enable = false },
							postfix = { enable = false },
						},
					},
				},
			},
		}

		for name, cfg in pairs(servers) do
			if next(cfg) then
				vim.lsp.config(name, cfg)
			end
		end
		vim.lsp.enable(vim.tbl_keys(servers))
	end,
}
