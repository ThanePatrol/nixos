local M = {}

M.on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
  end

  nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
  nmap("<leader>gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap("<leader>gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmap("<leader>gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
  nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
  nmap("<leader>g?", vim.diagnostic.open_float, "Show Diagnostic")
end

M.capabilities = require("cmp_nvim_lsp").default_capabilities()

return M
