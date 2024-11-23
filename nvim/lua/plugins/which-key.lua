---@type LazySpec
return {
  -- Which-key: Displays available keybindings in popup
  -- Shows possible key combinations and their descriptions when you start typing a command
  "folke/which-key.nvim",
  
  event = "VimEnter", -- Load when Neovim starts up
  
  opts = {
    icons = {
      -- Enable Nerd Font icons for key mappings if available
      mappings = vim.g.have_nerd_font,
      
      -- Configure key icons based on Nerd Font availability:
      -- If Nerd Font is present, use default Which-key icons
      -- Otherwise, use text-based fallback icons
      keys = vim.g.have_nerd_font and {} or {
        -- Navigation keys
        Up = "<Up> ",
        Down = "<Down> ",
        Left = "<Left> ",
        Right = "<Right> ",
        
        -- Modifier keys
        C = "<C-…> ",    -- Control
        M = "<M-…> ",    -- Meta/Alt
        D = "<D-…> ",    -- Command (macOS)
        S = "<S-…> ",    -- Shift
        
        -- Special keys
        CR = "<CR> ",              -- Enter/Return
        Esc = "<Esc> ",           -- Escape
        ScrollWheelDown = "<ScrollWheelDown> ",
        ScrollWheelUp = "<ScrollWheelUp> ",
        NL = "<NL> ",             -- New Line
        BS = "<BS> ",             -- Backspace
        Space = "<Space> ",
        Tab = "<Tab> ",
        
        -- Function keys
        F1 = "<F1>",
        F2 = "<F2>",
        F3 = "<F3>",
        F4 = "<F4>",
        F5 = "<F5>",
        F6 = "<F6>",
        F7 = "<F7>",
        F8 = "<F8>",
        F9 = "<F9>",
        F10 = "<F10>",
        F11 = "<F11>",
        F12 = "<F12>",
      },
    },
    
    -- Define key groups and their descriptions
    spec = {
      -- Leader key groups for different functionality domains
      { "<leader>c", group = "[C]ode", mode = { "n", "x" } },        -- Code actions
      { "<leader>d", group = "[D]ocument" },                         -- Document operations
      { "<leader>r", group = "[R]ename" },                          -- Renaming functionality
      { "<leader>s", group = "[S]earch" },                          -- Search operations
      { "<leader>w", group = "[W]orkspace" },                       -- Workspace actions
      { "<leader>m", group = "[M]eta",                              -- Meta commands
        { "<leader>ml", "<cmd>Lazy<CR>", desc = "Open [L]azy" }     -- Open Lazy plugin manager
      },
      -- Commented out for future use
      -- { "<leader>t", group = "[T]oggle" },
      
      -- Show buffer-local keymaps
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}
