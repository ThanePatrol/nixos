-- Various keymappings used for different purposes, excluding LSP + plugin specific mappings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- vim.api.nvim_set_keymap('n', 'tt', ':NvimTreeToggle<CR>',
--                        {noremap = true, silent = true})
-- vim.api.nvim_set_keymap('n', 'tf', ':NvimTreeFocus<CR>',
--                        {noremap = true, silent = true})

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

-- toggle case sensitive search
vim.api.nvim_set_keymap('n', '<leader>cs',
                        '<cmd>set ignorecase! ignorecase?<cr>',
                        {desc = 'toggle case sensitive search'})

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

-- Telescope begin
local telescope = require('telescope-module.telescope-cfg')

vim.keymap.set('n', '<leader>fg', telescope.multi_grep,
               {desc = "Find files with file type"})
vim.keymap.set('n', '<leader>ff', telescope.file_search,
               {desc = "Find files with fuzzy matching"})
vim.keymap.set('n', '<leader>ft', telescope.file_search_copy,
               {desc = "Find files with input prompt for copy and paste"})
vim.keymap.set('n', '<leader>ts', telescope.text_search, {desc = "Text search"})
-- find some emoji!
vim.keymap.set('n', '<leader>ie', telescope.emojis,
               {desc = "Open emoji picker 😀"})
vim.keymap.set('n', '<leader>fd', telescope.file_search_cwd,
               {desc = "Find files from the cwd of the open buffer"})
vim.keymap.set('n', '<leader>fc', telescope.text_search_cwd,
               {desc = "Find files with fuzzy matching from the cwd of buffer"})

-- Telescope end

-- Terminal begin
-- local termtoggle = require('term.nvim-term')
--
-- vim.keymap.set('n', 'to', termtoggle.toggleterm, {desc = 'toggle terminal'})
-- vim.keymap.set('t', 'tc', termtoggle.toggleterm,
--                {buffer = termtoggle.buf, desc = 'toggle terminal'})
-- Terminal end
--
-- Quickfix start
vim.api.nvim_command(
    "autocmd FileType qf nnoremap <buffer> dd :RemoveQFItem<cr>")
-- Quickfix end
--

-- Custom scripts start
local custom_text_objects = require('custom-scripts.scripts')
vim.keymap.set('n', 'vi`', function() custom_text_objects.inner_backtick() end,
               {desc = 'Visual inner backtick'})

vim.keymap.set('n', 'va`', function() custom_text_objects.around_backtick() end,
               {desc = 'Visual around backtick'})

local function file_path_to_clipboard()
    local file_path = vim.fn.expand('%')
    vim.fn.setreg('+', file_path)
end

vim.keymap.set('n', '<leader>d', file_path_to_clipboard)
-- Custom scripts end

-- Tabs start
vim.keymap.set('n', '<leader>t', '<cmd>tabnew<cr>', {desc = 'Open new tab'})

for i = 1, 9 do
    vim.keymap.set('n', '<leader>' .. i, '<cmd>' .. i .. 'tabnext<cr>',
                   {desc = 'Go to tab ' .. i})
end

vim.keymap.set('n', '<leader>w', '<cmd>tabclose<cr>', {desc = 'Close tab'})
-- Tabs end
--
-- Fyler start
local fyler_conf = require('fyler-config')
vim.keymap.set('n', 'tt', fyler_conf.open_at_cwd)
-- Fyler end
