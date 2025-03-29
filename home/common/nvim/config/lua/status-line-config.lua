require('lualine').setup({
    opts = {
        options = {
            icons_enabled = false,
            theme = 'onedark',
            component_separators = '|',
            section_separators = ''
        }
    },
    sections = { -- show recording macro in statusline
        lualine_x = {
            {
                require("noice").api.statusline.mode.get,
                cond = require("noice").api.statusline.mode.has,
                color = {fg = "#ff9e64"}
            }
        }
    }
})
