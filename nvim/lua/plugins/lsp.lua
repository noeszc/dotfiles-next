return {
  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },
  -- Main LSP Configuration
  "neovim/nvim-lspconfig",
  dependencies = { "j-hui/fidget.nvim" },
  event = "BufReadPre",
  config = function()
    local lsp = require("user.lsp")
    local utils = require("user.utils")

    utils.config_autocmd("LspAttach", {
      callback = function(e)
        local client = vim.lsp.get_client_by_id(e.data.client_id)

        if not client then
          return
        end

        lsp.on_attach(client, e.buf)
      end,
    })

    require("fidget").setup({
      progress = {
        display = { progress_icon = { "moon" } },
      },
    })
  end,
}
