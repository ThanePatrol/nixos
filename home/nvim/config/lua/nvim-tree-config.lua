require("nvim-tree").setup({
  hijack_directories = {
    enable = true,
    auto_open = true,
  },
  
  open_on_tab = true,
  view = {
	open_file = {
		resize_window = true,
	},
  },
})
