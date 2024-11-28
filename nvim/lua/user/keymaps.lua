-- Define local aliases for commonly used functions
local map = vim.keymap.set
local fn = vim.fn

-- Clear search highlighting with Escape
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic navigation and display
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Terminal mode mappings
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Discourage use of arrow keys in favor of hjkl
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Window navigation using Ctrl + hjkl
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Line movement mappings with OS-specific Alt key handling
-- On macOS, Alt+j produces ∆ and Alt+k produces ˚
local Aj = fn.has("macunix") == 1 and "<A-j>" or "<A-j>"
local Ak = fn.has("macunix") == 1 and "<A-k>" or "<A-k>"
-- Move lines up and down in normal and visual modes
map("n", Aj, ":m .+1<CR>==", { silent = true })      -- Move current line down
map("n", Ak, ":m .-2<CR>==", { silent = true })      -- Move current line up
map("v", Aj, ":m '>+1<CR>gv=gv", { silent = true })  -- Move selected lines down
map("v", Ak, ":m '<-2<CR>gv=gv", { silent = true })  -- Move selected lines up
