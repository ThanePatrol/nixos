return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	-- dependencies = {
	-- 	"williamboman/mason.nvim",
	-- 	"williamboman/mason-lspconfig.nvim",
	-- 	"WhoIsSethDaniel/mason-tool-installer.nvim",
	-- },
	config = function()
		local defaults = require("config.lsp_defaults")

		-- require("mason").setup()

		-- Install language servers
		-- require("mason-lspconfig").setup({
		-- 	ensure_installed = {
		-- 		"lua_ls",
		-- 		"gopls",
		-- 		"pyright",
		-- 		"clangd",
		-- 		"jdtls",
		-- 		"ts_ls",
		-- 		"bashls",
		-- 	},
		-- 	handlers = {},
		-- })

		-- Install formatters
		-- require("mason-tool-installer").setup({
		-- 	ensure_installed = {
		-- 		"stylua",
		-- 		"gofumpt",
		-- 		"goimports",
		-- 		"shfmt",
		-- 		"prettier",
		-- 		"black",
		-- 		"clang-format",
		-- 		"shellcheck",
		-- 	},
		-- })

		-- Enable language servers with defaults
		local function default_lsp_setup(module)
			vim.lsp.config(module, {
				on_attach = defaults.on_attach,
				capabilities = defaults.capabilities,
			})
			vim.lsp.enable(module)
		end

		-- Golang
		default_lsp_setup("gopls")

		-- Java: Use nvim-jdtls via ftplugin instead
		-- default_lsp_setup("jdtls")

		-- C/C++
		default_lsp_setup("clangd")

		-- Python
		default_lsp_setup("pyright")

		-- Typescript
		default_lsp_setup("ts_ls")

		-- Bash
		default_lsp_setup("bashls")

		-- Lua
		vim.lsp.config("lua_ls", {
			on_attach = defaults.on_attach,
			capabilities = defaults.capabilities,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
						-- Find Lua modules the same way as nvim, see :h lua-module-load
						path = {
							"lua/?.lua",
							"lua/?/init.lua",
						},
					},
					workspace = {
						checkThirdParty = false,
						library = { vim.env.VIMRUNTIME },
					},
				},
			},
		})
		vim.lsp.enable("lua_ls")
	end,
}
