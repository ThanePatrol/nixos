-- set default visualizer
require('telescope').setup({
    defaults = {
        layout_config = {horizontal = {width = 0.95}},
        mappings = {
            n = {
                ["p"] = function(prompt_bufnr)
                    local current_picker =
                        require('telescope.actions.state').get_current_picker(
                            prompt_bufnr)
                    local text = vim.fn.getreg('"')
                    local stripped = string.match(text, "^%s*(.-)%s*$")
                    current_picker:set_prompt(stripped, false)
                end
            }
        }
    }
})

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

M.multi_grep = function() live_multigrep() end
M.text_search = function()
    builtin.grep_string({search = vim.fn.input('Grep > ')})
end

M.file_search_copy = function()
    builtin.find_files({search_file = vim.fn.input('File Name > ')})
end

M.file_search = builtin.find_files
M.emojis = function() builtin.symbols() end

local dir_name_of_buf = function()
    return vim.fs.dirname(vim.api.nvim_buf_get_name(0))
end

M.file_search_cwd = function()
    builtin.find_files({search_dirs = {dir_name_of_buf()}})
end

M.text_search_cwd = function()
    builtin.grep_string({search_dirs = {dir_name_of_buf()}})
end

return M
