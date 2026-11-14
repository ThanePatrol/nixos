return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				python = { "ruff", "black", stop_after_first = true },
				lua = { "stylua" },
				sh = { "shfmt" },
				cpp = { "clang-format" },
				c = { "clang-format" },
				java = { "clang-format" },
				go = { "gofumpt", "goimports" },
				javascript = { "prettier" },
				typescript = { "prettier" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		})
	end,
}
