local util = require "formatter.util"

require("formatter").setup {
    logging = false,
    log_level = vim.log.levels.WARN,
    filetype = {
        lua = {
            function()
                return {
                    exe = "lua-format",
                    args = {vim.api.nvim_buf_get_name(0)},
                    stdin = true
                }
            end
        },

        nix = {
            function()
                return {
                    exe = "nixfmt",
                    --            args = {vim.api.nvim_buf_get_name(0)},
                    stdin = true
                }
            end
        },

        sh = {
            function()
                return {
                    exe = "shfmt",
                    args = {vim.api.nvim_buf_get_name(0)},
                    stdin = true
                }
            end
        },

        -- FIXME double check edge cases + add wsl
        go = {
            function()
                return {
                    exe = "gofumpt",
                    args = {vim.api.nvim_buf_get_name(0)},
                    stdin = true
                }
            end, function()
                return {
                    exe = "gofumpt",
                    args = {"-m", "128", vim.api.nvim_buf_get_name(0)},
                    stdin = true
                }
            end -- TODO add wsl when sysin is supported
        },

        py = {function() return {exe = "black", args = {"-"}} end},

        ["*"] = {require("formatter.filetypes.any").remove_trailing_whitespace}
    }
}
