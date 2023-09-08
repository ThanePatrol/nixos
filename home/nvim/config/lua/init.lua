vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.cmd.colorscheme "catppuccin"

-- highlight on search
vim.o.hlsearch = true

--line numbers
vim.wo.number = true

vim.o.mouse = 'a'

-- sync clipboard with OS
vim.o.clipboard = 'unnamedplus'

vim.o.breakindent = true

-- save undo history
vim.o.undofile = true

-- sign column
vim.wo.signcolumn = 'yes'

-- for better completion
vim.o.completeopt = 'menuone,noselect'

vim.o.termguicolors = true

require('catppuccin-config')
require('nvim-tree-config')
require('autopairs-config')
require('cmp-config')
require('lsp-config')
require('treesitter-config')
require('status-line-config')
