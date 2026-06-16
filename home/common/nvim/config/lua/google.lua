vim.filetype.add({pattern = {['.*pi'] = 'python', ['*.gcl'] = 'python'}})

require("critique.comments").setup({
    -- Don't automatically fetch comments after setup and on BufEnter events.
    auto_fetch = false,
    auto_render = false,
    debounce = 10000,
    display = {
        -- Max width in character to render a comment's text before wrapping to a newline.
        max_comment_width = 110,
        -- Render comment threads marked as resolved?
        render_resolved_threads = true
    },
    -- Debug message level
    debug = 0,
    verbose_notifications = true
})

-- Run visual selection in f1-sql and show in a new tab
local function run_f1_sql()
    -- Exit visual mode to save selection marks
    vim.cmd('normal! \x1b')
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line = start_pos[2]
    local end_line = end_pos[2]
    local start_col = start_pos[3]
    local end_col = end_pos[3]

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    if #lines == 0 then
        vim.notify("No text selected", vim.log.levels.WARN)
        return
    end

    local mode = vim.fn.visualmode()
    if mode == 'v' then
        if start_line == end_line then
            lines[1] = string.sub(lines[1], start_col, end_col)
        else
            lines[1] = string.sub(lines[1], start_col)
            lines[#lines] = string.sub(lines[#lines], 1, end_col)
        end
    elseif mode == '\22' then -- Block visual mode
        for i, line in ipairs(lines) do
            local s = math.min(start_col, end_col)
            local e = math.max(start_col, end_col)
            lines[i] = string.sub(line, s, e)
        end
    end

    local query = table.concat(lines, "\n")
    if query == "" then
        vim.notify("Selected query is empty", vim.log.levels.WARN)
        return
    end

    local buf_name = "F1-SQL Query Output" .. os.date("%Y-%m-%d %H:%M:%S")

    -- Create new buffer in a new tab
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    vim.api.nvim_buf_set_name(buf, buf_name)

    -- Required as newlines breaks the set_lines func.
    local single_line_query = string.gsub(query, "\n", " ")

    vim.cmd("tabnew")
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Running f1-sql...", "", "Query:", "```sql", single_line_query, "```",
        ""
    })

    local stdout_data = {}
    local stderr_data = {}

    local job_id = vim.fn.jobstart({'f1-sql'}, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data) stdout_data = data end,
        on_stderr = function(_, data) stderr_data = data end,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(buf) then return end

                local result = {}
                table.insert(result, "# F1-SQL Query Results")
                table.insert(result, "")
                table.insert(result, "## Query:")
                table.insert(result, "```sql")
                for _, l in ipairs(lines) do
                    table.insert(result, l)
                end
                table.insert(result, "```")
                table.insert(result, "")

                if exit_code == 0 then
                    table.insert(result, "## Output:")
                    for _, line in ipairs(stdout_data) do
                        table.insert(result, line)
                    end
                else
                    table.insert(result,
                                 "## Error (Exit Code: " .. exit_code .. ")")
                    table.insert(result, "### Stderr:")
                    table.insert(result, "```")
                    for _, line in ipairs(stderr_data) do
                        table.insert(result, line)
                    end
                    table.insert(result, "```")
                    table.insert(result, "")
                    table.insert(result, "### Partial Stdout:")
                    table.insert(result, "```")
                    for _, line in ipairs(stdout_data) do
                        table.insert(result, line)
                    end
                    table.insert(result, "```")
                end
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
            end)
        end
    })

    if job_id <= 0 then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false,
                                   {"Failed to start f1-sql process."})
        return
    end

    vim.fn.chansend(job_id, query)
    vim.fn.chanclose(job_id, 'stdin')
end

vim.keymap.set('v', '<Leader>f1', run_f1_sql,
               {desc = "Run selected query in f1-sql"})
