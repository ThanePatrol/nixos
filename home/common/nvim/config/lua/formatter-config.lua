local shell_formatter = function()
    return {exe = "shfmt", args = {"-"}, stdin = true}
end

local python_formatter = function()
    return {exe = "black", args = {"-"}, stdin = true}
end

-- FIXME add a startup of prettierd
local web_formatter = function()
    return {
        exe = "prettier",
        args = {vim.api.nvim_buf_get_name(0)},
        stdin = true
    }
end

local yaml_formatter = function()
    return {exe = "yamlfmt", args = {"-in"}, stdin = true}
end

require("formatter").setup {
    logging = false,
    log_level = vim.log.levels.WARN,
    filetype = {
        lua = {function() return {exe = "lua-format", stdin = true} end},

        nix = {function() return {exe = "nixfmt", stdin = true} end},

        yml = {yaml_formatter},
        yaml = {yaml_formatter},

        sh = {shell_formatter},
        bash = {shell_formatter},
        zsh = {shell_formatter},
        tmux = {shell_formatter},

        js = {web_formatter},
        ts = {web_formatter},
        css = {web_formatter},
        html = {web_formatter},
        jsx = {web_formatter},
        tsx = {web_formatter},

        go = {
            function()
                return {exe = "gofumpt", args = {}, stdin = true}
            end, function()
                return {exe = "golines", args = {"--max-len=128"}, stdin = true}
            end, function()
                return {
                    exe = "wsl",
                    args = {"-fix", vim.api.nvim_buf_get_name(0)},
                    stdin = false
                }
            end
        },

        -- FIXME  figure out why this is not working
        py = {function()
            return {exe = "black", args = {"-"}, stdin = true}
        end},
        ipynb = {python_formatter},

        ["*"] = {require("formatter.filetypes.any").remove_trailing_whitespace}
    }
}
