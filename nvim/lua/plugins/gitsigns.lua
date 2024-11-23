return {
  -- Git integration signs and blame information
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      -- Configure the signs shown in the gutter
      signs = {
        add = { text = "+" },          -- New lines added
        change = { text = "~" },        -- Lines modified
        delete = { text = "_" },        -- Lines deleted
        topdelete = { text = "‾" },     -- First line deleted when deleting a block
        changedelete = { text = "~" },  -- Lines modified then deleted
      },
      -- Enable inline git blame information
      current_line_blame = true,        -- Show commit info for current line
    },
  },
}
