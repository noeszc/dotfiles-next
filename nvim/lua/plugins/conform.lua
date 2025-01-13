---@type table<string, string[]>
local formatters_by_ft = {
  lua = { "stylua" },
}

-- List of filetypes that should use prettierd formatter
---@type string[]
local prettierd_ft = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "html",
  "css",
  "postcsss",
  "markdown",
  "json",
  "yaml",
}

-- Add prettierd formatter for each filetype
for _, ft in ipairs(prettierd_ft) do
  formatters_by_ft[ft] = { "prettierd" }
end

return {
  "stevearc/conform.nvim",
  -- Only load for filetypes that have formatters configured
  ft = vim.tbl_keys(formatters_by_ft),
  config = function()
    local conform = require("conform")
    local utils = require("user.utils")

    -- Configure conform.nvim with our formatter settings
    conform.setup({
      formatters_by_ft = formatters_by_ft,
    })

    -- Set up autoformatting on save
    utils.config_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(e)
        local filetype = vim.bo[e.buf].filetype

        -- Skip if no formatter configured or autoformat is disabled
        if not formatters_by_ft[filetype] or vim.g.disable_autoformat then
          return
        end

        -- Check for active ESLint LSP client
        local client = vim.lsp.get_active_clients({ buf = e.buf, name = "eslint" })[1]

        -- Format with ESLint if available
        ---@diagnostic disable-next-line: undefined-field
        if client then
          pcall(vim.lsp.buf.format, {
            async = false,
            timeout_ms = 4000,
          })
        end

        -- Format with conform.nvim
        pcall(conform.format, {
          bufnr = e.buf,
          timeout_ms = 1000,
          lsp_fallback = true, -- Fall back to LSP formatting if conform formatter fails
        })
      end,
    })

    -- Add command to toggle autoformatting
    vim.api.nvim_create_user_command("FormatToggle", function()
      vim.g.disable_autoformat = not vim.g.disable_autoformat
    end, {})
  end,
}
