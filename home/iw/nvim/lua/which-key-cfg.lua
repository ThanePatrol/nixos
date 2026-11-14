vim.keymap.set("n", "<leader>wk", function()
  require("which-key").show()
end, { desc = "Which-key toggle" })
