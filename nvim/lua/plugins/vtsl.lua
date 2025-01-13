return {
  -- Provides advanced LSP features specifically for TypeScript and JavaScript
  "yioneko/nvim-vtsls",

  -- Only load for TypeScript and JavaScript files
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },

  config = function()
    local lsp = require("user.lsp")

    require("lspconfig").vtsls.setup({
      handlers = lsp.handlers,
      on_attach = function(client, bufnr)
        lsp.on_attach(client, bufnr)
      end,
    })
  end,
}
