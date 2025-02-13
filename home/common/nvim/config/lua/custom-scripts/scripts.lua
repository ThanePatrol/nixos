local custom_text_objects = {}

-- Function to select the inner backtick-delimited text.
function custom_text_objects.inner_backtick()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local start_pos = nil
    local end_pos = nil

    -- Find the starting backtick.
    for i = cursor[2], 1, -1 do
        if string.sub(line, i, i) == '`' then
            start_pos = i
            break
        end
    end

    -- Find the ending backtick.
    for i = cursor[2], #line do
        if string.sub(line, i, i) == '`' then
            end_pos = i
            break
        end
    end
    -- Check that we find valid start and end characters
    if not start_pos or not end_pos or start_pos == end_pos then return end

    -- Set the visual selection (inner).
    vim.api.nvim_win_set_cursor(0, {cursor[1], start_pos})
    vim.cmd('normal! v') -- Explicitly enter visual mode.
    vim.api.nvim_win_set_cursor(0, {cursor[1], end_pos - 1})

end

-- Function to select the backtick-delimited text, including the backticks.
function custom_text_objects.around_backtick()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local start_pos = nil
    local end_pos = nil

    -- Find the starting backtick.
    for i = cursor[2], 1, -1 do
        if string.sub(line, i, i) == '`' then
            start_pos = i
            break
        end
    end

    -- Find the ending backtick.
    for i = cursor[2], #line do
        if string.sub(line, i, i) == '`' then
            end_pos = i
            break
        end
    end

    -- Check that we find valid start and end characters
    if not start_pos or not end_pos or start_pos == end_pos then return end

    -- Set the visual selection (around).
    vim.api.nvim_win_set_cursor(0, {cursor[1], start_pos - 1})
    vim.cmd('normal! v')
    vim.api.nvim_win_set_cursor(0, {cursor[1], end_pos})
end

-- Set up the keymaps.
--  Use 'omap' (operator-pending mode map) to make this work with operators like d, c, y.
-- vim.keymap.set('o', 'i`', function() custom_text_objects.inner_backtick() end, { expr = true, desc = "Inner backtick text object" })
-- vim.keymap.set('o', 'a`', function() custom_text_objects.around_backtick() end, { expr = true, desc = "Around backtick text object" })

