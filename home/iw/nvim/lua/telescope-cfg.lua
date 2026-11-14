local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>tf", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>ts", builtin.grep_string, { desc = "Telescope find strings" })

require("telescope").setup({
  defaults = {
  	layout_config = {
  		horizontal = {
  			preview_cutoff = 0,
  		},
  	},
  	path_display = "shorten",
  },
  -- Find-files includes dots, excludes .git/ and gitignored files
  pickers = {
  	find_files = {
  		find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
  	},
  	grep_string = {
  		hidden = true,
  	},
  },
})
