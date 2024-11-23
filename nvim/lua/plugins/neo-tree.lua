return {
    -- Neo-tree: A file explorer tree for Neovim
    -- Provides a modern, feature-rich file browser with Git integration
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',      -- Lua utility functions
      'nvim-tree/nvim-web-devicons', -- File icons support
      'MunifTanjim/nui.nvim',       -- UI component library
    },
    cmd = 'Neotree', -- Load only when Neotree command is used
    keys = {
      -- Key mappings for Neo-tree operations
      {
        '\\',
        ':Neotree reveal<CR>',
        desc = 'NeoTree reveal', -- Show current file in tree
        silent = true
      },
      {
        '<leader>e',
        function()
          -- Toggle tree visibility and set root to current working directory
          require('neo-tree.command').execute {
            toggle = true,
            dir = vim.loop.cwd()
          }
        end,
        desc = 'Explorer NeoTree (cwd)',
      },
    },
    opts = {
      filesystem = {
        bind_to_cwd = false,        -- Don't change directory when opening files
        follow_current_file = {
          enabled = true            -- Keep tree in sync with current file
        },
        use_libuv_file_watcher = true, -- Use efficient file watching
        filtered_items = {
          visible = true,           -- Show filtered items in the tree
        },
        window = {
          mappings = {
            ['\\'] = 'close_window', -- Close tree with same key that opens it
          },
        },
      },
    },
  }
