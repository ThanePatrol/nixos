local nvim_lsp = require('lspconfig')

local on_attach = function(client, bufnr)
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    local nmap = function(keys, func, desc)
        if desc then desc = 'LSP: ' .. desc end
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end
    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references,
         '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols,
         '[D]ocument [S]ymbols')
    nmap('<leader>ws',
         require('telescope.builtin').lsp_dynamic_workspace_symbols,
         '[W]orkspace [S]ymbols')
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    --  nmap('g?', vim.lsp.diagnostic.show_line_diagnostics, 'Show error message in floating window')
    -- todo -rest of kickstart on_attach
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- enable LSPs
local function default_lsp_setup(module)
    nvim_lsp[module].setup(
        { on_attach = on_attach, capabilities = capabilities })
end

default_lsp_setup('bashls')
-- default_lsp_setup("rust_analyzer")
default_lsp_setup('nil_ls') -- nix
default_lsp_setup('pyright')
default_lsp_setup('lua_ls')
default_lsp_setup('cssls')
-- default_lsp_setup("html")
default_lsp_setup('jsonls')
default_lsp_setup('ccls') -- c/c++
default_lsp_setup('metals') -- scala
default_lsp_setup('texlab') -- latex
default_lsp_setup('gopls') -- go

nvim_lsp.rust_analyzer.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        ['rust_analyzer'] = {
            cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
            cargo = { allFeatures = true },
            procMacro = { enable = true },
            diagnostics = { experimental = { enable = true } },
        },
    },
})

nvim_lsp.tsserver.setup({
    init_options = require('nvim-lsp-ts-utils').init_options,
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)

        -- todo, let ESlint handle formatting
        local ts_utils = require('nvim-lsp-ts-utils')
        ts_utils.setup({ enable_import_on_completion = true })
        ts_utils.setup_client(client)

        -- todo, add mappings
    end,
    capabilities = capabilities,
    filetypes = {
        'javascript', 'javascriptreact', 'javascript.jsx', 'typescript',
        'typescriptreact', 'typescript.tsx',
    },
})

nvim_lsp.html.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { 'html', 'rust' },
    configurationSection = { 'html', 'css', 'javascript' },
    embeddedLanguages = { css = true, javascript = true },
    provideFormatter = true,
})

nvim_lsp.terraformls.setup({
	filetypes = { "terraform", "tf" , "hcl"},
})

