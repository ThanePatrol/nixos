local nvim_lsp = require("lspconfig")

local on_attach = function(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end
  
  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  
  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  --todo -rest of kickstart on_attach
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

--enable LSPs
local function default_lsp_setup(module)
  nvim_lsp[module].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

default_lsp_setup("bashls")
default_lsp_setup("rust-analyzer")
default_lsp_setup("nil")
default_lsp_setup("pyright")
--default_lsp_setup("lua
--default_lsp_setup("cssls") todo - double check implementation
--default_lsp_setup("html")
--default_lsp_setup("jsonls")

