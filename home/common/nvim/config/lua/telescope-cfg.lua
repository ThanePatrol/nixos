local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>tf', builtin.find_files, {})
vim.keymap.set('n', '<leader>ts', function()
    builtin.grep_string({search = vim.fn.input('Grep > ')})
end)

-- find some emoji!
vim.keymap.set('n', '<leader>ie', builtin.symbols, {})
