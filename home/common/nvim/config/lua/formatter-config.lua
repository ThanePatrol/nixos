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

local file_types_for_work = function()
    if require('utils').is_cloudtop() then
        return {
            go = {google3_formatter},
            cpp = {google3_formatter},
            java = {google3_formatter},
            markdown = {google3_formatter},
            sql = {google3_formatter},
            textproto = {google3_formatter},
            bzl = {google3_formatter}
        }

    else
        return {
            cpp = require('formatter.filetypes.cpp').clangformat,
            python = {python_formatter},
            go = {
                function()
                    return {exe = "gofumpt", args = {}, stdin = true}
                end, function()
                    return
                        {
                            exe = "golines",
                            args = {"--max-len=128"},
                            stdin = true
                        }
                end, function()
                    return {
                        exe = "wsl",
                        args = {"-fix", vim.api.nvim_buf_get_name(0)},
                        stdin = false
                    }
                end
            }
        }
    end
end

local different_files = file_types_for_work()
local universal_files = {
    lua = require('formatter.filetypes.lua').luaformat,

    nix = require('formatter.filetypes.nix').nixfmt,

    latex = require("formatter.filetypes.latex").latexindent,
    rust = require('formatter.filetypes.rust').rustfmt,

    yml = {yaml_formatter},
    yaml = {yaml_formatter},

    sh = {shell_formatter},
    bash = {shell_formatter},
    zsh = {shell_formatter},
    tmux = {shell_formatter},

    ipynb = {python_formatter},

    js = {web_formatter},
    ts = {web_formatter},
    css = {web_formatter},
    html = {web_formatter},
    jsx = {web_formatter},
    tsx = {web_formatter},

    ["*"] = {
        function()
            return {exe = "sed", args = {"s/[ \t]*$//"}, stdin = true}
        end, function()
            return {
                exe = "keep-sorted",
                args = {"--default-options='block=yes'", "-"},
                stdin = true
            }
        end
    }
}

local function merge_dicts(t1, t2)
    for key, value in pairs(t1) do t2[key] = value end
    return t2
end
local final_files = merge_dicts(different_files, universal_files)

require("formatter").setup {
    logging = false,
    log_level = vim.log.levels.WARN,
    filetype = final_files
}
