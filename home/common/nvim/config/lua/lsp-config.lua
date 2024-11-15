local navic = require('nvim-navic')
local nvim_lsp = require('lspconfig')

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local function save_to_file(file_name, to_save)
    str = dump(to_save)
    local file = io.open(file_name, "w")
    file:write(str)
    file:close()
end

local function save_references_to_table()
    local references = {}

    local function on_list(options)
        for _, item in pairs(options.items) do
            table.insert(references, item)
        end
    end

    vim.lsp.buf.references(nil, {on_list = on_list})

    return references
end

local function capture_references()
    local params = vim.lsp.util.make_position_params()

    -- Table to store filenames
    local filenames = {}

    -- Custom handler to capture filenames
    local function references_handler(err, result, ctx, config)
        if err then
            vim.notify(err.message, vim.log.levels.WARN)
            return
        end
        if result then
            for _, ref in ipairs(result) do
                local uri = ref.uri
                local filename = vim.uri_to_fname(uri)
                table.insert(filenames, filename)
            end
        end
        save_to_file("/tmp/filesss", filenames)
        -- Output or use the filenames table as needed
        print(vim.inspect(filenames))
    end

    -- Request references with custom handler
    vim.lsp
        .buf_request(0, 'textDocument/references', params, references_handler)
end

local function refactor_functions_and_logging()
    local curr_name = vim.fn.expand("<cword>")
    local new_name = vim.fn.input("New name: ", curr_name)

    -- local files = save_references_to_table()
    -- save_to_file("/tmp/filesss", files)
    -- capture_references()

    if not new_name or #new_name == 0 or new_name == curr_name then
        return -- Do nothing if the name is not changed
    end

    -- 	local original_handler = vim.lsp.handlers["textDocument/rename"]
    -- 	vim.lsp.handlers["textDocument/rename"] = function (err, result, ctx, config)
    -- 		if original_handler then
    -- 			original_handler(err, result, ctx, config)
    -- 		end
    --
    --
    -- 	end
    --
    -- 	vim.lsp.handlers["textDocument/rename"] = vim.lsp.with(
    -- 		vim.lsp.diagnostic.
    -- 	)

    vim.lsp.buf.rename(new_name)

    -- Get current filetypes
    local curr_filetype = vim.bo.filetype
    local file_extension = vim.fn.expand("%:e")

    -- FIXME do something like below
    -- Basically loop through all open buffers, apply the changes to the open files then apply changes to saved files
    -- prevents changing files that have an open buffers
    -- for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    --     if vim.api.nvim_buf_is_loaded(buf) then
    --         local file_str = tostring(vim.api.nvim_buf_get_name(buf))
    --         print(file_str)
    --         local regex = "/"
    --         local file_st = file_str:gsub(regex, "-")
    --         local file_name = "/tmp/"
    --         file_name = file_name .. file_st
    --         print(file_name)
    --         save_to_file(file_name, buf)
    --     end
    -- end

    -- local files = vim.api.nvim_list_bufs()
    -- print(dump(files))

    -- local cmd = string.format(
    --                 "rg --files-with-matches --type %s --glob '*.%s' '%s' | xargs sed -i '' 's/\\[%s\\]/\\[%s\\]/g'",
    --                 curr_filetype, file_extension, curr_name, curr_name,
    --                 new_name)
    -- print(cmd)
    -- os.execute(cmd)
end

local on_attach = function(client, bufnr)
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- FIXME not working
    -- breadcrumb provider
    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    local nmap = function(keys, func, desc)
        if desc then desc = 'LSP: ' .. desc end
        vim.keymap.set('n', keys, func, {buffer = bufnr, desc = desc})
    end

    nmap('<leader>rn', refactor_functions_and_logging, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('<leader>gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('<leader>gr', require('telescope.builtin').lsp_references,
         '[G]oto [R]eferences')
    nmap('<leader>gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols,
         '[D]ocument [S]ymbols')
    nmap('<leader>ws',
         require('telescope.builtin').lsp_dynamic_workspace_symbols,
         '[W]orkspace [S]ymbols')
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    nmap('<leader>g?', vim.diagnostic.open_float,
         'Show error message in floating window')
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- enable LSPs
local function default_lsp_setup(module)
    nvim_lsp[module].setup({on_attach = on_attach, capabilities = capabilities})
end

nvim_lsp['bashls'].setup({
    on_attach = on_attach,
    bashIde = {globPattern = "*@(.sh|.inc|.bash|.command|.tmux)"}
})

default_lsp_setup('nil_ls') -- nix
default_lsp_setup('pyright') -- python
default_lsp_setup('cssls') -- css
default_lsp_setup('jsonls') -- json
default_lsp_setup('clangd') -- c/c++
default_lsp_setup('texlab') -- latex
default_lsp_setup('postgres_lsp')
default_lsp_setup('marksman') -- markdown
default_lsp_setup('thriftls')
default_lsp_setup('ts_ls')

nvim_lsp.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {Lua = {diagnostics = {globals = {'vim'}}}}
})

require('rust-tools').setup({
    server = {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            cargo = {allFeatures = true},
            procMacro = {enable = true},
            diagnostics = {experimental = {enable = true}}
        }
    },
    tools = {
        runnables = {use_telescope = true},
        inlay_hints = {
            auto = true,
            show_parameter_hints = false,
            parameter_hints_prefix = '',
            other_hints_prefix = ''
        },
        reload_workspace_from_cargo_toml = true
    }
})

nvim_lsp.gopls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        gopls = {
            analyses = {unusedparams = true},
            staticcheck = true,
            usePlaceholders = true,
            -- To use gopls in files with exclusive buildFlags
            buildFlags = {"-tags=integration,unit"}
        }
    }
})

nvim_lsp.html.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = {'html', 'rust'},
    configurationSection = {'html', 'css', 'javascript'},
    embeddedLanguages = {css = true, javascript = true},
    provideFormatter = true
})

nvim_lsp.terraformls.setup({filetypes = {'terraform', 'tf', 'hcl'}})

nvim_lsp.glslls.setup {}
