-- highlight on search
vim.o.hlsearch = true

-- line numbers
vim.wo.number = true

vim.o.mouse = 'a'

-- sync clipboard with OS
vim.o.clipboard = 'unnamedplus'

vim.o.breakindent = true

-- save undo history
vim.o.undofile = true

-- set tab spaces
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- sign column
vim.wo.signcolumn = 'yes'

vim.opt.relativenumber = true

require('mappings')
require('color-theme')
vim.cmd.colorscheme "catppuccin"
-- Fix colorscheme.
vim.opt.termguicolors = true
require('nvim-tree-config')
require('autopairs-config')
require('cmp-config')
require('lsp-config')
require('treesitter-config')
require('status-line-config')
require('rust')
require('indent-blankline-config')
require('vim-tmux')
require('telescope-cfg')
-- require('debugger')
require('git-cfg')
require('precognition-config')
