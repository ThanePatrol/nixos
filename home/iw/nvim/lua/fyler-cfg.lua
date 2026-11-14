local fyler = require("fyler")

fyler.setup({
	views = {
		finder = {
			close_on_select = false,
		},
	},
})

vim.keymap.set("n", "<leader>ft", function()
	fyler.open({ kind = "split_left_most" })
end, { desc = "Open Fyler view" })
