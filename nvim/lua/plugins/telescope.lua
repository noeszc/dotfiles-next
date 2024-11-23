return {
  -- Telescope: A highly extendable fuzzy finder for Neovim
  -- Provides powerful search capabilities across files, buffers, LSP symbols, and more
  "nvim-telescope/telescope.nvim",
  event = "VimEnter", -- Load when Neovim starts
  branch = "0.1.x",   -- Use stable release branch
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for async operations

    -- Native FZF sorter for better performance
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make", -- Compile C code on install/update
      cond = function()
        return vim.fn.executable("make") == 1 -- Only install if make is available
      end,
    },

    -- UI Select integration for better LSP experience
    { "nvim-telescope/telescope-ui-select.nvim" },

    -- File icons support (requires Nerd Font)
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
  },

  config = function()
    -- Configure Telescope with custom settings and extensions
    require("telescope").setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(), -- Use dropdown theme for UI select
        },
      },
    })

    -- Load optional extensions safely
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")

    -- Set up keymaps for Telescope functionality
    local builtin = require("telescope.builtin")

    -- Core search functionality
    vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
    vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
    vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
    vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

    -- Documentation and help
    vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
    vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
    vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })

    -- Development tools
    vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
    vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
    vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })

    -- Advanced search configurations
    -- Fuzzy find in current buffer with dropdown theme
    vim.keymap.set("n", "<leader>/", function()
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,     -- Slight transparency
        previewer = false, -- Disable preview for faster interaction
      }))
    end, { desc = "[/] Fuzzily search in current buffer" })

    -- Search only in open files
    vim.keymap.set("n", "<leader>s/", function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
      })
    end, { desc = "[S]earch [/] in Open Files" })

    -- Quick access to Neovim config files
    vim.keymap.set("n", "<leader>sn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "[S]earch [N]eovim files" })
  end,
}
