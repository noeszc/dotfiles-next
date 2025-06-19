return {
  -- Mason: Package manager for LSP servers, DAP servers, linters, and formatters
  "williamboman/mason.nvim",
  dependencies = {
    -- Bridge between Mason and LSP config
    "williamboman/mason-lspconfig.nvim",
    -- Automated tool installer for Mason packages
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  event = "BufReadPre", -- Load when starting to read a buffer
  cmd = "Mason", -- Also load when :Mason command is used
  config = function()
    local mason_lspconfig = require("mason-lspconfig")
    local tool_installer = require("mason-tool-installer")
    local lsp = require("user.lsp")

    -- Initialize Mason with default settings
    require("mason").setup({})

    -- Configure automatic installation of LSP servers
    mason_lspconfig.setup({
      automatic_enable = false,
      ensure_installed = {
        "lua_ls", -- Lua language server
        "rust_analyzer", -- Rust language server
        "eslint", -- JavaScript/TypeScript linter
        "stylelint_lsp", -- CSS/SCSS/Less linter
        "vtsls",
      },
    })

    -- Configure automatic installation of additional tools
    tool_installer.setup({
      ensure_installed = {
        -- Linters
        "luacheck", -- Lua static analyzer

        -- Formatters
        "prettierd", -- Fast JavaScript/TypeScript/CSS formatter
        "stylua", -- Lua code formatter
      },
    })

    -- Install configured tools on startup
    tool_installer.run_on_start()

    -- Set up each installed LSP server with custom configuration
    for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
      local serverConfig = require("lspconfig")[server]
      local setupObject = {
        -- Use custom LSP handlers from user config
        handlers = lsp.handlers,

        -- Configure server behavior when attaching to buffers
        on_attach = function(client, bufnr)
          -- Apply common LSP configurations
          lsp.on_attach(client, bufnr)

          -- Enable document formatting for ESLint
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
            client.server_capabilities.documentRangeFormattingProvider = true
          end
        end,
      }

      -- Special configuration for stylelint_lsp
      if serverConfig.name == "stylelint_lsp" then
        -- Add PostCSS support while preserving default filetypes
        setupObject.filetypes = { "postcss", unpack(serverConfig.document_config.default_config.filetypes or {}) }
      end

      -- Initialize the LSP server with our configuration
      serverConfig.setup(setupObject)
    end
  end,
}
