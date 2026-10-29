vim.filetype.add({pattern = {['.*pi'] = 'python', ['*.gcl'] = 'python'}})

require("critique.comments").setup({
    -- Automatically fetch comments after setup and on BufEnter events.
    auto_fetch = true,
    auto_render = true,
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
                -- Subtract 5 because of markdown formatting that is output.
                -- This should be something cleaner but it works...
                table.insert(result, "Returned " .. #stdout_data - 5 .. " rows")
                table.insert(result, "```sql")
                for _, l in ipairs(lines) do
                    table.insert(result, l)
                end
                table.insert(result, "```")
                table.insert(result, "")
                -- Reduce max bytes to 5MiB by default as over that it can cause the UI to stall.
                local max_bytes = 5 * 2 ^ 20

                local n_bytes = 0

                if exit_code == 0 then
                    table.insert(result, "## Output:")
                    for _, line in ipairs(stdout_data) do
                        n_bytes = n_bytes + #line
                        if n_bytes > max_bytes then break end
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
                if n_bytes > max_bytes then
                    vim.notify(string.format("Only displaying %e of total",
                                             n_bytes), vim.log.levels.INFO)
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
    vim.notify("Query finished in buf" .. tostring(buf), vim.log.levels.INFO)
end

local function open_bugged_edit(bug_id)
    local function start_edit(id)
        if not id or id == "" then return end
        -- Strip leading b/ if present
        id = id:gsub("^b/", "")

        vim.cmd("tabnew")
        local buf = vim.api.nvim_get_current_buf()
        vim.bo[buf].buftype = "acwrite"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].swapfile = false
        -- 'mail' highlights '> ' quotes and headers nicely; or use 'markdown'
        vim.bo[buf].filetype = "mail"
        vim.api.nvim_buf_set_name(buf, "bugged://" .. id)

        vim.api.nvim_buf_set_lines(buf, 0, -1, false,
                                   {"*** Loading bug " .. id .. " ..."})

        vim.system({"bugged", "show", id}, {text = true}, function(res)
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(buf) then return end
                if res.code ~= 0 then
                    vim.notify("bugged show failed: " .. (res.stderr or ""),
                               vim.log.levels.ERROR)
                    return
                end

                local lines = {
                    "*** Please enter your comments below. Save (:w) to post to b/" ..
                        id .. ".",
                    "*** Entering text below a quote ('> ') includes that quote in the comment.",
                    "", ""
                }
                for _, line in ipairs(vim.split(res.stdout or "", "\n",
                                                {plain = true})) do
                    table.insert(lines, line)
                end

                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                vim.bo[buf].modified = false
                vim.api.nvim_win_set_cursor(0, {4, 0})
            end)
        end)

        vim.api.nvim_create_autocmd("BufWriteCmd", {
            buffer = buf,
            callback = function()
                local content = table.concat(
                                    vim.api.nvim_buf_get_lines(buf, 0, -1, false),
                                    "\n") .. "\n"
                vim.notify("Updating b/" .. id .. "...", vim.log.levels.INFO)

                vim.system({"bugged", "edit", id},
                           {stdin = content, text = true}, function(res)
                    vim.schedule(function()
                        if res.code == 0 then
                            if vim.api.nvim_buf_is_valid(buf) then
                                vim.bo[buf].modified = false
                            end
                            vim.notify(vim.trim(
                                           res.stdout ~= "" and res.stdout or
                                               ("Updated b/" .. id)),
                                       vim.log.levels.INFO)
                        else
                            vim.notify("bugged edit failed:\n" ..
                                           (res.stderr or ""),
                                       vim.log.levels.ERROR)
                        end
                    end)
                end)
            end
        })
    end

    if bug_id and bug_id ~= "" then
        start_edit(bug_id)
        return
    end

    -- Pre-fill prompt if cursor is on b/<number> or a number
    local cfile = vim.fn.expand("<cfile>")
    local default_id = cfile:match("^b/(%d+)$") or cfile:match("^(%d+)$") or ""
    vim.ui.input({
        prompt = "Bug ID (e.g. 123456, 123456.1, 123456.status): ",
        default = default_id
    }, start_edit)
end
vim.keymap.set("n", "<Leader>be", open_bugged_edit,
               {desc = "[B]ugged [E]dit in new tab"})

vim.keymap.set('v', '<Leader>f1', run_f1_sql,
               {desc = "Run selected query in f1-sql"})
