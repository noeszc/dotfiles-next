return {
  -- Autocompletion plugin with LSP, snippet, and path support
  "hrsh7th/nvim-cmp",
  event = "InsertEnter", -- Load when entering insert mode
  dependencies = {
    -- Snippet engine with regex support
    {
      "L3MON4D3/LuaSnip",
      build = (function()
        -- Build step needed for regex support in snippets
        -- Skip build on Windows or if make is not available
        if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
          return
        end
        return "make install_jsregexp"
      end)(),
      dependencies = {
        -- Optional: Uncomment to enable VSCode-style snippets
        -- {
        --   'rafamadriz/friendly-snippets',
        --   config = function()
        --     require('luasnip.loaders.from_vscode').lazy_load()
        --   end,
        -- },
      },
    },
    "saadparwaiz1/cmp_luasnip", -- LuaSnip completion source

    -- Additional completion sources
    "hrsh7th/cmp-nvim-lsp", -- LSP completion
    "hrsh7th/cmp-path", -- Filesystem path completion
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    luasnip.config.setup({})

    cmp.setup({
      -- Configure snippet expansion
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- Configure completion behavior
      completion = {
        completeopt = "menu,menuone,noinsert", -- Show menu, even with one item, don't auto-insert
      },

      -- Key mappings for completion and snippet navigation
      mapping = cmp.mapping.preset.insert({
        -- Completion navigation
        ["<C-n>"] = cmp.mapping.select_next_item(), -- Next item
        ["<C-p>"] = cmp.mapping.select_prev_item(), -- Previous item
        ["<Tab>"] = cmp.mapping.select_next_item(), -- Alternative next
        ["<S-Tab>"] = cmp.mapping.select_prev_item(), -- Alternative previous

        -- Documentation scrolling
        ["<C-b>"] = cmp.mapping.scroll_docs(-4), -- Scroll up
        ["<C-f>"] = cmp.mapping.scroll_docs(4), -- Scroll down

        -- Completion acceptance
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept selected item

        -- Manual completion trigger
        ["<C-Space>"] = cmp.mapping.complete({}), -- Force completion menu

        -- Snippet navigation
        ["<C-l>"] = cmp.mapping(function() -- Jump forward in snippet
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { "i", "s" }),
        ["<C-h>"] = cmp.mapping(function() -- Jump backward in snippet
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { "i", "s" }),
      }),

      -- Configure completion sources and their priority
      sources = {
        {
          name = "lazydev",
          group_index = 0, -- Skip LuaLS completions as recommended
        },
        { name = "nvim_lsp" }, -- LSP completions
        { name = "luasnip" }, -- Snippet completions
        { name = "path" }, -- Path completions
      },
    })
  end,
}
