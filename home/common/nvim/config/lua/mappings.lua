-- Various keymappings used for different purposes, excluding LSP + plugin specific mappings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.api.nvim_set_keymap('n', 'tt', ':NvimTreeToggle<CR>',
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'tf', ':NvimTreeFocus<CR>',
                        {noremap = true, silent = true})

vim.api.nvim_set_keymap('n', 'g?', '<cmd>lua vim.diagnostic.open_float()<CR>',
                        {noremap = true, silent = true}) -- expand error messages

-- Toggle breakpoint
vim.api.nvim_set_keymap('n', '<leader>db', '<cmd>DapToggleBreakpoint <CR>',
                        {noremap = true, silent = true})

-- Step over breakpoint
vim.api.nvim_set_keymap('n', '<leader>do', '<cmd>DapStepOver <CR>',
                        {noremap = true, silent = true})

-- Continue execution
vim.api.nvim_set_keymap('n', '<leader>dc', '<cmd>DapContinue <CR>',
                        {noremap = true, silent = true})

-- View debug window
vim.api.nvim_set_keymap('n', '<leader>dvs',
                        '<cmd>lua local widgets = require("dap.ui.widgets"); local sidebar = widgets.sidebar(widgets.scopes); sidebar.open(); <CR>',
                        {noremap = true, silent = true})

-- in visual mode surround selection
vim.keymap.set("x", "'", [[:s/\%V\(.*\)\%V/'\1'/ <CR>]],
               {desc = "Surround selection with '"})
vim.keymap.set("x", '"', [[:s/\%V\(.*\)\%V/"\1"/ <CR>]],
               {desc = 'Surround selection with "'})

-- in normal mode surround word
vim.keymap.set("n", '<leader>s"', [[:s/\<<C-r><C-w>\>/"<C-r><C-w>\"/ <CR>]],
               {desc = 'Surround word with "'})
vim.keymap.set("n", "<leader>s'", [[:s/\<<C-r><C-w>\>/'<C-r><C-w>\'/ <CR>]],
               {desc = "Surround word with '"})

-- Trouble.lua start
vim.api.nvim_set_keymap('n', '<leader>xx',
                        '<cmd>Trouble diagnostics toggle<cr>', {
    silent = true,
    noremap = true,
    desc = "Diagnostics (Trouble)"
})
vim.api.nvim_set_keymap('n', '<leader>xX',
                        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', {
    silent = true,
    noremap = true,
    desc = "Buffer Diagnostics (Trouble)"
})
vim.api.nvim_set_keymap('n', '<leader>cs',
                        '<cmd>Trouble symbols toggle focus=false<cr>', {
    silent = true,
    noremap = true,
    desc = "Symbols (Trouble)"
})
vim.api.nvim_set_keymap('n', '<leader>cl',
                        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
                        {
    silent = true,
    noremap = true,
    desc = "LSP Definitions / references / ... (Trouble)"
})
vim.api.nvim_set_keymap('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', {
    silent = true,
    noremap = true,
    desc = "Location List (Trouble)"
})
vim.api.nvim_set_keymap('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', {
    silent = true,
    noremap = true,
    desc = "Quickfix List (Trouble)"
})

-- Trouble.lua end

-- formatter.nvim start
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup("__formatter__", {clear = true})
autocmd("BufWritePost", {group = "__formatter__", command = ":FormatWrite"})
-- formatter.nvim end

-- vim test start
vim.api.nvim_set_keymap('n', '<leader>t', '<cmd>TestNearest<cr>')
vim.api.nvim_set_keymap('n', '<leader>T', '<cmd>TestFile<cr>')
vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>TestSuite<cr>')
vim.api.nvim_set_keymap('n', '<leader>l', '<cmd>TestLast<cr>')
vim.api.nvim_set_keymap('n', '<leader>g', '<cmd>TestVisit<cr>')
-- vim test end
