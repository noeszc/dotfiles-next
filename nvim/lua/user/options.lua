-- Import utility function for creating autocommands
local config_autocmd = require("user.utils").config_autocmd

-- Disable filetype-based indentation
vim.cmd("filetype indent off")

-- Set leader keys for custom mappings
vim.g.mapleader = " " -- Space as the main leader key
vim.g.maplocalleader = " " -- Space as the local leader key
vim.g.have_nerd_font = false -- Disable Nerd Font features

-- Line numbering settings
vim.opt.number = true -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers for easier navigation

-- Input and editing settings
vim.opt.mouse = "a" -- Enable mouse support in all modes
vim.opt.tabstop = 2 -- Number of spaces a tab counts for
vim.opt.shiftwidth = 2 -- Number of spaces for auto-indentation

-- Schedule clipboard setting to avoid startup issues
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus" -- Use system clipboard
end)

-- Line wrapping settings
vim.opt.wrap = true -- Enable line wrapping
vim.opt.linebreak = true -- Wrap at word boundaries
vim.opt.showbreak = "↪ " -- Indicator for wrapped lines

-- Editor behavior settings
vim.opt.breakindent = false -- Don't maintain indent when wrapping
vim.opt.undofile = true -- Persistent undo history
vim.opt.ignorecase = true -- Case-insensitive search
vim.opt.smartcase = true -- Case-sensitive if search contains uppercase
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.updatetime = 250 -- Faster update time for better UX
vim.opt.timeoutlen = 300 -- Time to wait for mapped sequence
vim.opt.splitright = true -- Open vertical splits to the right
vim.opt.splitbelow = true -- Open horizontal splits below

-- Visual indicators
vim.opt.list = true -- Show invisible characters
vim.opt.listchars = { -- Define invisible character representations
  tab = "» ", -- Tab character
  trail = "·", -- Trailing spaces
  nbsp = "␣", -- Non-breaking space
}
vim.opt.inccommand = "split" -- Show effects of substitution in split
vim.opt.cursorline = true -- Highlight current line
vim.opt.scrolloff = 10 -- Keep 10 lines visible above/below cursor

-- Search settings
vim.opt.hlsearch = true -- Highlight search matches

-- Configure yank highlighting
-- Creates a brief highlight effect when yanking text
-- Try it with `yap` in normal mode to yank a paragraph
-- See `:help vim.highlight.on_yank()`
config_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})
