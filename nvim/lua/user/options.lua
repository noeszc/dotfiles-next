local config_autocmd = require("user.utils").config_autocmd

vim.cmd("filetype indent off")
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "

vim.opt.breakindent = false
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10

vim.opt.hlsearch = true

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()
config_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})
