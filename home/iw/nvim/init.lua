-- Load plugins
-- require("config.lazy")
-- require("config.lazy")

vim.g.mapleader = " "

vim.opt.clipboard = "unnamedplus"

vim.opt.number = true
vim.opt.relativenumber = true

vim.cmd("syntax on")
vim.o.termguicolors = true

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- Disable comment leader continuation. See :help fo-table
vim.opt.formatoptions:remove({ "r", "o" })

vim.keymap.set("n", "<ESC>", ":noh<CR>", { desc = "Clear search highlighting", silent = true })

vim.cmd("colorscheme duskfox")

require("telescope-keymaps")
require("treesitter-cfg")

-- vim.keymap.set("n", "<leader>wk", require("which-key").show(), { desc = "Which-key toggle" })

-- vim.keymap.set("n", "<leader>ft", function()
--   require("fyler").open({ kind = "split_left_most" })
-- end, { desc = "Open Fyler view" })

-- Disable completion for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    require("cmp").setup.buffer({
      enabled = false,
    })
  end,
})

-- Autotoggle relative line numbers based on context
local numbertogglegroup = vim.api.nvim_create_augroup("numbertoggle", { clear = true })

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  pattern = "*",
  callback = function()
    vim.wo.relativenumber = true
  end,
  group = numbertogglegroup,
})

vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  pattern = "*",
  callback = function()
    vim.wo.relativenumber = false
  end,
  group = numbertogglegroup,
})
