local nvim_lsp = require('lspconfig')

local function refactor_functions_and_logging()
    local curr_name = vim.fn.expand("<cword>")
    local new_name = vim.fn.input("New name: ", curr_name)

    if not new_name or #new_name == 0 or new_name == curr_name then return end

    vim.lsp.buf.rename(new_name)
end

local on_attach = function(client, bufnr)
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
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
default_lsp_setup('rust_analyzer')

nvim_lsp.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {Lua = {diagnostics = {globals = {'vim'}}}}
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
    filetypes = {'html'},
    configurationSection = {'html', 'css', 'javascript'},
    embeddedLanguages = {css = true, javascript = true},
    provideFormatter = true
})

nvim_lsp.terraformls.setup({filetypes = {'terraform', 'tf', 'hcl'}})

nvim_lsp.glslls.setup {}
