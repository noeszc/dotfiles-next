return {
  -- TypeScript Tools: Enhanced TypeScript/JavaScript development support
  -- Provides advanced LSP features specifically for TypeScript and JavaScript
  "pmizio/typescript-tools.nvim",
  
  -- Only load for TypeScript and JavaScript files
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  
  config = function()
    -- Import required modules
    local lsp = require("user.lsp")
    local utils = require("user.utils")

    -- Safely require typescript-tools
    local ok, tst = pcall(require, "typescript-tools")

    -- Skip setup if typescript-tools not found or Vue.js is installed
    -- (Vue.js projects typically use Volar instead)
    if not ok or utils.is_npm_installed("vue") then
      return
    end

    -- Configure typescript-tools with custom settings
    tst.setup({
      -- Use custom LSP handlers from user config
      handlers = lsp.handlers,

      -- Configure behavior when attaching to buffers
      on_attach = function(client, bufnr)
        -- Disable document formatting capabilities
        -- This allows other formatters (like prettier) to handle formatting
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        -- Apply common LSP configurations
        lsp.on_attach(client, bufnr)
      end,

      settings = {
        -- Run diagnostics in a separate process for better performance
        separate_diagnostic_server = true,
        composite_mode = "separate_diagnostic",
        
        -- Only publish diagnostics when leaving insert mode
        -- This reduces noise while typing
        publish_diagnostic_on = "insert_leave",
        
        -- Enable for detailed tsserver logs during debugging
        -- tsserver_logs = "verbose",
        
        -- Configure TypeScript server preferences
        tsserver_file_preferences = {
          -- Use non-relative imports for better maintainability
          importModuleSpecifierPreference = "non-relative",
        },
      },
    })
  end,
}
