return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
	},
	keys = {
		-- { "<leader>cd", vim.diagnostic.open_float, desc = "Show diagnostic" }, using custom function based on snacks
		{ "<leader>ca", vim.lsp.buf.code_action, desc = "Show code actions" },
		{ "K", vim.lsp.buf.hover, desc = "Hover documentation", mode = "n" },
		{ "gd", vim.lsp.buf.definition, desc = "Go to definition" },
		{ "gr", vim.lsp.buf.references, desc = "Show references" },
		{ "<leader>cr", vim.lsp.buf.rename, desc = "Rename symbol" },
		{ "[d", vim.diagnostic.goto_prev, desc = "Previous diagnostic" },
		{ "]d", vim.diagnostic.goto_next, desc = "Next diagnostic" },
	},
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()
		-- Configuración de diagnósticos
		vim.diagnostic.config({
			signs = true,
			underline = true,
			virtual_text = true,
			update_in_insert = true,
			severity_sort = true,
		})
		-- Configuración de servidores LSP usando la nueva API
		local servers = {
			lua_ls = {
				capabilities = capabilities,
			},
			clangd = {
				capabilities = capabilities,
			},
			basedpyright = {
				capabilities = capabilities,
				settings = {
					basedpyright = {
						analysis = {
							autoSearchPaths = true,
							diagnosticMode = "openFilesOnly",
							useLibraryCodeForTypes = true,
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
			bashls = {
				capabilities = capabilities,
			},
			tinymist = {
				capabilities = capabilities,
				settings = {
					formatterMode = "typstyle",
					exportPdf = "onType",
					outputPath = "/$name",
					semanticTokens = "disable",
				},
			},
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
						chktex = { onEdit = true },
					},
				},
			},
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
			rust_analyzer = {
				capabilities = capabilities,
				settings = {
					["rust-analyzer"] = {
						checkOnSave = {
							command = "clippy",
						},
						procMacro = {
							enable = true,
						},
						cargo = {
							allFeatures = true,
						},
					},
				},
			},
		}

		-- Configurar cada servidor
		for server_name, config in pairs(servers) do
			vim.lsp.config(server_name, config)
		end
	end,
}
