local M = {}

function M.is_cloudtop() return vim.env.CORP_WORK_ENV == "true" end

-- TODO: In markdown files have a util function to preview currently selected mermaid blocks in visual mode
-- by:
-- 1. Generate a svg somewhere in /tmp
-- 2. Serve the svg in a web server Something like python3 -m http.server <path-to-svg>
-- Also have another binding to save it as a png.
-- Also include mmdc in nvvim required packages + python3 so guaranteed to work.
--
--
-- TODO: Make generic function for this as it's used in a few places
--- @return string[]
function M.get_text_in_visual_mode()
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
        return {}
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
    return lines
end

function M.preview_svg() end
function M.preview_svg() end

return M
