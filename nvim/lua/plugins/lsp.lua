return {
  -- LSP (Language Server Protocol) related plugins
  {
    -- LazyDev: Enhanced Lua LSP configuration for Neovim
    -- Provides intelligent code completion, type checking, and documentation
    -- for Neovim's Lua API, runtime, and plugin development
    "folke/lazydev.nvim",
    ft = "lua", -- Only load for Lua files
    opts = {
      library = {
        -- Configure type definitions for vim.uv (libuv bindings)
        -- Only loads when vim.uv is referenced in code
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },

  -- Type definitions for vim.uv (libuv bindings)
  -- Required by LazyDev for enhanced UV API support
  { "Bilal2453/luvit-meta", lazy = true },

  -- Core LSP client configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Elegant LSP progress indicator
      "j-hui/fidget.nvim"
    },
    event = "BufReadPre", -- Load when starting to read a buffer
    config = function()
      -- Import LSP and utility modules
      local lsp = require("user.lsp")
      local utils = require("user.utils")

      -- Set up autocommand for LSP client attachment
      -- This runs whenever a language server attaches to a buffer
      utils.config_autocmd("LspAttach", {
        callback = function(e)
          -- Get the LSP client that just attached
          local client = vim.lsp.get_client_by_id(e.data.client_id)

          -- Guard against invalid client
          if not client then
            return
          end

          -- Configure buffer-local LSP settings
          lsp.on_attach(client, e.buf)
        end,
      })

      -- Configure fidget.nvim for LSP progress display
      require("fidget").setup({
        progress = {
          display = { progress_icon = { "moon" } }, -- Use moon icon for progress indication
        },
      })
    end,
  }
}
