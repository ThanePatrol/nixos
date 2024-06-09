local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    local nmap = function(keys, func, desc)
        if desc then desc = 'LSP: ' .. desc end
        vim.keymap.set('n', keys, func, {buffer = bufnr, desc = desc})
    end
    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
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
default_lsp_setup('pyright')
default_lsp_setup('cssls')
default_lsp_setup('jsonls')
default_lsp_setup('clangd') -- c/c++
default_lsp_setup('texlab') -- latex
default_lsp_setup('postgres_lsp')
default_lsp_setup('marksman')

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
            usePlaceholders = true
        }
    }
})

nvim_lsp.tsserver.setup({
    init_options = require('nvim-lsp-ts-utils').init_options,
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = {
        'javascript', 'javascriptreact', 'javascript.jsx', 'typescript',
        'typescriptreact', 'typescript.tsx'
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

