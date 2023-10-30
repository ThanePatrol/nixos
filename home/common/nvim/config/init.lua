vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Fix colorscheme.
vim.opt.termguicolors = true
-- vim.cmd([[ set t_8f=^[[38;2;%lu;%lu;%lum ]])
-- vim.cmd([[ set t_8b=^[[48;2;%lu;%lu;%lum ]])
vim.cmd.colorscheme 'catppuccin'

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

-- for better completion
vim.o.completeopt = 'menuone,noselect'

vim.api.nvim_set_keymap('n', 'tt', ':NvimTreeToggle<CR>',
                        { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'tf', ':NvimTreeFocus<CR>',
                        { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', 'g?', '<cmd>lua vim.diagnostic.open_float()<CR>',
                        { noremap = true, silent = true }) -- expand error messages
-- autoformat python, use callback for a vim function, command for a shell function
-- vim.api.nvim_create_autocmd('BufWritePost', {
--	pattern = "*.py",
--	callback = vim.cmd(':!black %')
-- })

-- vim.api.nvim_create_autocmd('BufWritePre', {
--	desc = 'format python on write using black',
--
--	group = vim.api.nvim_create_augroup('black_on_save', { clear = true }),
--	callback = function (opts)
--		if vim.bo[opts.buf].filetype == 'python' then
--			vim.cmd '!black %'
--		end
--	end,
-- })

vim.opt.relativenumber = true

vim.g.rustfmt_autosave = 1, require('catppuccin-config')
require('nvim-tree-config')
require('autopairs-config')
require('cmp-config')
require('lsp-config')
require('treesitter-config')
require('status-line-config')
require('formatting')
require('rust')
require('indent-blankline-config')
require('vim-tmux')
require('pilot')
require('neorg-cfg')
require('telescope-cfg')
