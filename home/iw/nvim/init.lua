vim.g.mapleader = " "

-- Options

vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.timeout = true
vim.opt.timeoutlen = 500

vim.cmd("colorscheme duskfox")
vim.cmd("syntax on")

vim.o.termguicolors = true

vim.keymap.set("n", "<ESC>", ":noh<CR>", { desc = "Clear search highlighting", silent = true })

-- Plugins

require("telescope-cfg")
require("treesitter-cfg")

require("which-key-cfg")
require("fyler-cfg")
require("render-markdown-cfg")

require("lsp-cfg")
require("cmp-cfg")
require("conform-cfg")

-- Autocommands

-- Toggle relative line numbers
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
