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

