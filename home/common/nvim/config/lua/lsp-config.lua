local function refactor_functions()
    local curr_name = vim.fn.expand("<cword>")
    local new_name = vim.fn.input("New name: ", curr_name)

    if not new_name or #new_name == 0 or new_name == curr_name then return end

    vim.lsp.buf.rename(new_name)
end

local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local nmap = function(keys, func, desc)
        if desc then desc = 'LSP: ' .. desc end
        vim.keymap.set('n', keys, func, {buffer = bufnr, desc = desc})
    end

    nmap('<leader>rn', refactor_functions, '[R]e[n]ame')
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

local function default_lsp_setup(module)
    vim.lsp.config(module, {on_attach = on_attach, capabilities = capabilities})
    vim.lsp.enable(module)
end

default_lsp_setup('bashls')
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
default_lsp_setup('lua_ls')
default_lsp_setup('gopls')
default_lsp_setup('terraformls')
default_lsp_setup('html')
