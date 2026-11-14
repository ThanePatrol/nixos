local lspconfig = require("lspconfig")
local defaults = require("lsp-defaults")

local function default_lsp_setup(module)
	vim.lsp.config(module, {
		on_attach = defaults.on_attach,
		capabilities = defaults.capabilities,
		-- Can add filetypes, settings
	})
	vim.lsp.enable(module)
end

-- Golang
default_lsp_setup("gopls")

-- Java: Use nvim-jdtls via ftplugin instead

-- C/C++
default_lsp_setup("clangd")

-- Python
default_lsp_setup("pyright")

-- Kotlin
default_lsp_setup("kotlin_lsp")

-- Bash
default_lsp_setup("bashls")

-- Rust
default_lsp_setup("rust_analyzer")

-- Lua
vim.lsp.config("lua_ls", {
	on_attach = defaults.on_attach,
	capabilities = defaults.capabilities,
	filetypes = { "lua" },
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			runtime = {
				version = "LuaJIT",
				-- Find Lua modules the same way as nvim, see :h lua-module-load
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			signatureHelp = { enabled = true },
			workspace = {
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME },
			},
		},
	},
})
vim.lsp.enable("lua_ls")
