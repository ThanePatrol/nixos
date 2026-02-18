local shell_formatter = function()
    return {exe = "shfmt", args = {"-"}, stdin = true}
end

local comment_formatter = function()
    return {exe = "fmt", args = {"-w", "80", "p", "//"}, stdin = true}
end

local google3_formatter = function()
    local full_path = vim.api.nvim_buf_get_name(0)
    local maybe_index = string.find(full_path, "google3")

    if maybe_index == nil then return {} end

    -- string.find returns tuple, first element is the one
    local cut_path = string.sub(full_path, maybe_index)
    local full_path_with_prefix = string.format("//depot/%s", cut_path)

    return {
        exe = "google3format",
        args = {"--depot_path", full_path_with_prefix, "--whole_file"},
        stdin = true
    }
end

local python_formatter = function()
    return {
        exe = "black",
        args = {
            "--quiet", "--stdin-filename", vim.api.nvim_buf_get_name(0), "-"
        },
        stdin = true
    }
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
        lua = require('formatter.filetypes.lua').luaformat,

        nix = require('formatter.filetypes.nix').nixfmt,

        latex = require("formatter.filetypes.latex").latexindent,
        cpp = require('formatter.filetypes.cpp').clangformat,
        rust = require('formatter.filetypes.rust').rustfmt,

        yml = {yaml_formatter},
        yaml = {yaml_formatter},

        sh = {shell_formatter},
        bash = {shell_formatter},
        zsh = {shell_formatter},
        tmux = {shell_formatter},

        python = {python_formatter},
        ipynb = {python_formatter},

        -- FIXME  figure the file types that correspond here
        js = {web_formatter},
        ts = {web_formatter},
        css = {web_formatter},
        html = {web_formatter},
        jsx = {web_formatter},
        tsx = {web_formatter},

        ["*"] = {require("formatter.filetypes.any").remove_trailing_whitespace}
    }
}
