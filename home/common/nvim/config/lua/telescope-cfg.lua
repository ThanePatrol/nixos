local builtin = require('telescope.builtin')

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local conf = require('telescope.config').values

local M = {}

local live_multigrep = function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or vim.fn.getcwd()

    local finder = finders.new_async_job {
        command_generator = function(prompt)
            if not prompt or prompt == "" then return nil end
            local pieces = vim.split(prompt, "  ")
            local args = {"rg"}
            if pieces[1] then
                table.insert(args, "-e")
                table.insert(args, pieces[1])
            end

            if pieces[2] then
                table.insert(args, "-g")
                table.insert(args, pieces[2])
            end

            return vim.tbl_flatten {
                args, {
                    "--color=never", "--no-heading", "--with-filename",
                    "--line-number", "--column", "--smart-case"
                }
            }
        end,
        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = opts.cwd
    }

    pickers.new(opts, {
        finder = finder,
        prompt_title = "Multi Grep",
        debounce = 100,
        previewer = conf.grep_previewer(opts),
        sorter = require('telescope.sorters').empty()
    }):find()
end

M.setup = function() live_multigrep() end

vim.keymap.set('n', '<leader>tg', live_multigrep)
vim.keymap.set('n', '<leader>tf', builtin.find_files, {})
vim.keymap.set('n', '<leader>ts', function()
    builtin.grep_string({search = vim.fn.input('Grep > ')})
end)

-- find some emoji!
vim.keymap.set('n', '<leader>ie', builtin.symbols, {})
