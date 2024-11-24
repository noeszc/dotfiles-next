return {
  -- Todo Comments: Highlight special comments like TODO, NOTE, etc.
  -- Provides visual distinction for important notes in code comments
  {
    "folke/todo-comments.nvim",
    event = "VimEnter", -- Load when Neovim starts
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false }, -- Disable gutter signs
  },

  -- Comment.nvim: Smart code commenting
  -- Provides commands to comment/uncomment code blocks
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, "gcc" }, -- Toggle comments with 'gc' in normal/visual mode
    },
    opts = {
      -- Integration with ts-context-commentstring for language-aware commenting
      pre_hook = function(ctx)
        return require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()(ctx)
      end,
    },
  },

  -- Context Commentstring: Language-aware comment strings
  -- Ensures correct comment syntax in different contexts (e.g., JSX/TSX)
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    ft = { "typescriptreact" }, -- Load only for TypeScript React files
    opts = {
      enable_autocmd = false, -- Disable automatic loading
    },
  },

  -- TS Autotag: Automatically close HTML/JSX tags
  -- Updates closing tags when editing opening tags and vice versa
  { "windwp/nvim-ts-autotag", event = "InsertEnter", opts = {} },

  -- Autopairs: Smart bracket/quote pairing
  -- Automatically inserts closing brackets, quotes, etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter", -- Load when entering insert mode
    dependencies = { "hrsh7th/nvim-cmp" }, -- Optional CMP integration
    config = function()
      require("nvim-autopairs").setup({})
      -- Add parentheses after completing function or method
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Template String: Smart template string conversion
  -- Automatically converts quotes to template strings when needed
  {
    "axelvc/template-string.nvim",
    opts = {
      filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" },
      remove_template_string = true, -- Remove template string when no interpolation
      restore_quotes = {
        normal = [[']], -- Single quotes for normal strings
        jsx = [["]], -- Double quotes for JSX attributes
      },
    },
    event = "InsertEnter",
    ft = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" },
  },

  -- Mini.nvim: Collection of independent Neovim plugins
  -- Provides various text editing enhancements
  {
    "echasnovski/mini.nvim",
    config = function()
      -- Mini.ai: Enhanced text objects
      -- Provides smarter around/inside operations
      require("mini.ai").setup({ n_lines = 500 }) -- Limit search to 500 lines

      -- Mini.surround: Surround text operations
      -- Adds, deletes, or replaces surrounding characters
      require("mini.surround").setup()

      -- Mini.statusline: Minimal status line
      -- Provides essential information in a clean format
      local statusline = require("mini.statusline")
      statusline.setup({ use_icons = vim.g.have_nerd_font })

      -- Customize statusline location section
      -- Shows cursor position as LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end
    end,
  },
}
