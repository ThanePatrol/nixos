local M = {}
require("fyler").setup({integrations = {icon = "nvim_web_devicons"}})

M.open_at_cwd = function()
    local cwd = vim.fn.expand("%:h")
    require('fyler').toggle({dir = cwd, kind = 'split_left'})
end

return M
