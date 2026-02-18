-- highlight on search
vim.o.hlsearch = true

-- line numbers
vim.wo.number = true

vim.o.mouse = 'a'

-- sync clipboard with OS
vim.o.clipboard = 'unnamedplus'

-- ignore case
vim.opt.ignorecase = true
-- unless capitals in search term
vim.opt.smartcase = true

-- Keep context around cursor
vim.opt.scrolloff = 10

-- Open vsplits to the right
vim.opt.splitright = true

vim.opt.smartindent = true
vim.o.breakindent = true

-- automatically reload file from disk if buffer hasn't changed
vim.opt.autoread = true

-- save undo history
vim.o.undofile = true

-- set tab spaces
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- sign column
vim.wo.signcolumn = 'yes'

vim.opt.relativenumber = true

-- diff view start
vim.opt.fillchars = {diff = '/'}

vim.opt.diffopt = {
    'internal', 'filler', 'closeoff', 'context:12', 'algorithm:histogram',
    'linematch:200', 'indent-heuristic', 'inline:word'
}
-- diff view end

-- virtual text for lsp info
vim.diagnostic.config({virtual_lines = false})

vim.cmd.colorscheme "catppuccin-mocha"
vim.opt.termguicolors = true

require('mappings')

require('mappings')
require('cmp-config')
require('lsp-config')
require('treesitter-config')
require('status-line-config')
require('indent-blankline-config')
require('git-cfg')
require('trouble-config')
require('render-markdown-config')
require('formatter-config')
require('harpoon-config')
require('quickfix')
require('codecompanion-config')
require('fyler-config')

local function require_module_if_not_macos(module_name)
    local os_name = vim.fn.has('macunix') and vim.fn.has('unix') and
                        vim.fn.has('mac') and "macos" or vim.fn.has('win32') and
                        "windows" or "other"
    if os_name ~= "macos" then require(module_name) end
end
