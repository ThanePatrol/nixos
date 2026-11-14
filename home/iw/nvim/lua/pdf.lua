return {
	-- Requires pdftotext
	"basola21/PDFview",
	event = "BufRead *.pdf",
	dependencies = { "nvim-telescope/telescope.nvim" },
	config = function()
		-- Keymaps to navigate pages
		vim.api.nvim_set_keymap(
			"n",
			"<leader>jj",
			"<cmd>:lua require('pdfview.renderer').next_page()<CR>",
			{ desc = "PDFview: Next page" }
		)
		vim.api.nvim_set_keymap(
			"n",
			"<leader>kk",
			"<cmd>:lua require('pdfview.renderer').previous_page()<CR>",
			{ desc = "PDFview: Previous page" }
		)
		-- View PDF upon read
		vim.api.nvim_create_autocmd("BufReadPost", {
			pattern = "*.pdf",
			callback = function()
				local file_path = vim.api.nvim_buf_get_name(0)
				require("pdfview").open(file_path)
			end,
		})
	end,
}
