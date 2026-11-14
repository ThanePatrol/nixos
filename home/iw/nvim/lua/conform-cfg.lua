require("conform").setup({
	formatters_by_ft = {
		python = { "ruff" },
		lua = { "stylua" },
		sh = { "shfmt" },
		cpp = { "clang-format" },
		c = { "clang-format" },
		java = { "google-java-format" },
		go = { "gofumpt", "goimports" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})
