return {
  -- Treesitter: Advanced syntax highlighting and code navigation
  -- Provides intelligent parsing and analysis of source code for better highlighting,
  -- indentation, and code manipulation capabilities
  "nvim-treesitter/nvim-treesitter",
  
  -- Automatically update parsers when plugin is installed/updated
  build = ":TSUpdate",
  
  -- Configure via nvim-treesitter.configs module
  main = "nvim-treesitter.configs",
  
  opts = {
    -- Languages to install parsers for
    ensure_installed = {
      "javascript", -- JavaScript support
      "typescript", -- TypeScript support
    },

    -- Automatically install parsers for new filetypes
    auto_install = true,

    -- Configure syntax highlighting
    highlight = {
      enable = true,
      
      -- Ruby requires vim's regex highlighting for proper indentation
      -- Add other languages here if experiencing indentation issues
      additional_vim_regex_highlighting = { "ruby" },
    },

    -- Configure automatic indentation
    indent = {
      enable = true,
      disable = { "ruby" }, -- Disable for Ruby due to regex dependency
    },

    -- Configure text objects for syntax-aware selection
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ab"] = { query = "@braces.around", query_group = "surroundings" },
          ["ib"] = { query = "@braces.inner", query_group = "surroundings" },
          ["aq"] = { query = "@quotes.around", query_group = "surroundings" },
          ["iq"] = { query = "@quotes.inner", query_group = "surroundings" },
        },
      },
    },
  },

  -- Additional recommended modules:
  -- 1. Incremental selection - Built-in, extends selection based on syntax tree
  --    See: `:help nvim-treesitter-incremental-selection-mod`
  --
  -- 2. Context display - Shows code context in floating window
  --    Plugin: nvim-treesitter/nvim-treesitter-context
  --
  -- 3. Text objects - Provides syntax-aware text objects
  --    Plugin: nvim-treesitter/nvim-treesitter-textobjects
}
