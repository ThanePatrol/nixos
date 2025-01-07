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
vim.api.nvim_set_keymap('n', '<leader>tn', '<cmd>TestNearest<cr>', {
    silent = true,
    noremap = true,
    desc = "Test the nearest individual test. Test Nearest"
})
vim.api.nvim_set_keymap('n', '<leader>TT', '<cmd>TestFile<cr>', {
    silent = true,
    noremap = true,
    desc = "Run all tests in the file. Test This"
})
vim.api.nvim_set_keymap('n', '<leader>ta', '<cmd>TestSuite<cr>', {
    silent = true,
    noremap = true,
    desc = "Run the entire test suite. Test All"
})
vim.api.nvim_set_keymap('n', '<leader>tl', '<cmd>TestLast<cr>', {
    silent = true,
    noremap = true,
    desc = "Test the most recently tested test. Test Last"
})
vim.api.nvim_set_keymap('n', '<leader>tv', '<cmd>TestVisit<cr>', {
    silent = true,
    noremap = true,
    desc = "See the latest test. Test Visit"

})
-- vim test end

-- GP nvim start
local function keymapOptions(desc)
    return {
        noremap = true,
        silent = true,
        nowait = true,
        desc = "GPT prompt " .. desc
    }
end

-- Chat commands
vim.keymap.set({"n", "i"}, "<C-g>c", "<cmd>GpChatNew<cr>",
               keymapOptions("New Chat"))
vim.keymap.set({"n", "i"}, "<C-g>t", "<cmd>GpChatToggle<cr>",
               keymapOptions("Toggle Chat"))
vim.keymap.set({"n", "i"}, "<C-g>f", "<cmd>GpChatFinder<cr>",
               keymapOptions("Chat Finder"))

vim.keymap.set("v", "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>",
               keymapOptions("Visual Chat New"))
vim.keymap.set("v", "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>",
               keymapOptions("Visual Chat Paste"))
vim.keymap.set("v", "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>",
               keymapOptions("Visual Toggle Chat"))

vim.keymap.set({"n", "i"}, "<C-g><C-x>", "<cmd>GpChatNew split<cr>",
               keymapOptions("New Chat split"))
vim.keymap.set({"n", "i"}, "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>",
               keymapOptions("New Chat vsplit"))
vim.keymap.set({"n", "i"}, "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>",
               keymapOptions("New Chat tabnew"))

vim.keymap.set("v", "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>",
               keymapOptions("Visual Chat New split"))
vim.keymap.set("v", "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>",
               keymapOptions("Visual Chat New vsplit"))
vim.keymap.set("v", "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>",
               keymapOptions("Visual Chat New tabnew"))

-- Prompt commands
vim.keymap.set({"n", "i"}, "<C-g>r", "<cmd>GpRewrite<cr>",
               keymapOptions("Inline Rewrite"))
vim.keymap.set({"n", "i"}, "<C-g>a", "<cmd>GpAppend<cr>",
               keymapOptions("Append (after)"))
vim.keymap.set({"n", "i"}, "<C-g>b", "<cmd>GpPrepend<cr>",
               keymapOptions("Prepend (before)"))

vim.keymap.set("v", "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>",
               keymapOptions("Visual Rewrite"))
vim.keymap.set("v", "<C-g>a", ":<C-u>'<,'>GpAppend<cr>",
               keymapOptions("Visual Append (after)"))
vim.keymap.set("v", "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>",
               keymapOptions("Visual Prepend (before)"))
vim.keymap.set("v", "<C-g>i", ":<C-u>'<,'>GpImplement<cr>",
               keymapOptions("Implement selection"))

vim.keymap
    .set({"n", "i"}, "<C-g>gp", "<cmd>GpPopup<cr>", keymapOptions("Popup"))
vim.keymap
    .set({"n", "i"}, "<C-g>ge", "<cmd>GpEnew<cr>", keymapOptions("GpEnew"))
vim.keymap.set({"n", "i"}, "<C-g>gn", "<cmd>GpNew<cr>", keymapOptions("GpNew"))
vim.keymap
    .set({"n", "i"}, "<C-g>gv", "<cmd>GpVnew<cr>", keymapOptions("GpVnew"))
vim.keymap.set({"n", "i"}, "<C-g>gt", "<cmd>GpTabnew<cr>",
               keymapOptions("GpTabnew"))

vim.keymap.set({"n", "i"}, "<C-g>x", "<cmd>GpContext<cr>",
               keymapOptions("Toggle Context"))
vim.keymap.set("v", "<C-g>x", ":<C-u>'<,'>GpContext<cr>",
               keymapOptions("Visual Toggle Context"))

vim.keymap.set({"n", "i", "v", "x"}, "<C-g>s", "<cmd>GpStop<cr>",
               keymapOptions("Stop"))
vim.keymap.set({"n", "i", "v", "x"}, "<C-g>n", "<cmd>GpNextAgent<cr>",
               keymapOptions("Next Agent"))

-- gp nvim end

-- Telescope begin
local telescope = require('telescope-module.telescope-cfg')

vim.keymap.set('n', '<leader>tg', telescope.multi_grep,
               {desc = "Find files with file type"})
vim.keymap.set('n', '<leader>tf', telescope.file_search, {desc = "Find files"})
vim.keymap.set('n', '<leader>ts', telescope.text_search, {desc = "Text search"})
-- find some emoji!
vim.keymap.set('n', '<leader>ie', telescope.emojis,
               {desc = "Open emoji picker 😀"})

-- Telescope end

-- Terminal begin
local termtoggle = require('term.nvim-term')

vim.keymap.set('n', 'to', termtoggle.toggleterm, {desc = 'toggle terminal'})
vim.keymap.set('t', 'tc', termtoggle.toggleterm,
               {buffer = termtoggle.buf, desc = 'toggle terminal'})
-- Terminal end
--
-- Quickfix start
vim.api.nvim_command(
    "autocmd FileType qf nnoremap <buffer> dd :RemoveQFItem<cr>")
-- Quickfix end
