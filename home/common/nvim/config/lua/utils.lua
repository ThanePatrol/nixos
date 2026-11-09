local M = {}

function M.is_cloudtop() return vim.env.CORP_WORK_ENV == "true" end

-- TODO: In markdown files have a util function to preview currently selected mermaid blocks in visual mode
-- by:
-- 1. Generate a svg somewhere in /tmp
-- 2. Serve the svg in a web server Something like python3 -m http.server <path-to-svg>
-- Also have another binding to save it as a png.
-- Also include mmdc in nvvim required packages + python3 so guaranteed to work.
--
--- Gets the text in visual mode in a table.
--- table[i] is the i`th row of the visual selection.
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

---@param port integer The port to listen on.
---@param svg_path string The absolute path to the svg to serve.
---@return function stop The function to stop the server.
function M.start_server_on_port(port, svg_path)
    local uv = vim.uv
    -- local response_body = string.format("<img src=%s>", svg_path)
    local response_body = "<h1>Hello from Neovim vim.uv!</h1>"
    local http_rsp = string.format("HTTP/1.1 200 OK\r\n" ..
                                       "Content-Type: text/html; charset=utf-8\r\n" ..
                                       "Content-Length: %d\r\n" ..
                                       "Connection: close\r\n\r\n%s",
                                   #response_body, response_body)

    local server = uv.new_tcp()

    assert(server:bind("127.0.0.1", port))

    server:listen(128, function(err)
        assert(not err, err)
        local client = uv.new_tcp()
        server:accept(client)
        client:read_start(function(err, chunk)
            assert(not err, err)
            vim.schedule(function()
                vim.notify(string.format("Client read of chunk: %s", chunk),
                           vim.log.levels.WARN)

            end)
            if chunk then
                client:write(http_rsp)
            else
                client:shutdown()
                client:close()
            end
        end)
    end)

    -- Don't bother cleaning up client connections.
    local function stop_server()
        if not server:is_closing() then server:close() end
    end

    return stop_server
end

return M
