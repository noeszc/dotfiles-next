-- Define local aliases for commonly used functions
local map = vim.keymap.set
local fn = vim.fn

-- Clear search highlighting with Escape
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic navigation and display
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Terminal mode mappings
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Discourage use of arrow keys in favor of hjkl
map("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
map("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
map("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
map("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Window navigation using Ctrl + hjkl
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Line movement mappings with OS-specific Alt key handling
-- local Aj = fn.has("macunix") == 1 and "<A-j>" or "<A-j>"
-- local Ak = fn.has("macunix") == 1 and "<A-k>" or "<A-k>"
-- map("n", Aj, ":m .+1<CR>==", { silent = true }) -- Move current line down
-- map("n", Ak, ":m .-2<CR>==", { silent = true }) -- Move current line up
-- map("v", Aj, ":m '>+1<CR>gv=gv", { silent = true }) -- Move selected lines down
-- map("v", Ak, ":m '<-2<CR>gv=gv", { silent = true }) -- Move selected lines up

-- Line jumps
-- map("n", "H", "^", { noremap = true, silent = true }) -- Map H to move to the beginning of the line
-- map("n", "L", "g_", { noremap = true, silent = true }) -- Map L to move to the last line of the screen

-- Fix indenting using < and >
map("v", ">", ">gv")
map("v", "<", "<gv")

-- Yank and paste to system clipboard
map({ "n", "v" }, "gp", "+p", { silent = true })
map({ "n", "v" }, "gP", "+P", { silent = true })
map({ "n", "v" }, "gy", "+y", { silent = true })
map({ "n", "v" }, "gY", "+Y", { silent = true })

-- Remap n to also center search result
map("n", "n", "nzzzv")
map("n", "<C-d>", "<C-d>zzzv")
map("n", "<C-u>", "<C-u>zzzv")

-- Calc
map("n", "<leader>m", '"zcc<C-r>=<C-r>z<CR><ESC>', { silent = true })
map("v", "<leader>m", '"zc<C-r>=<C-r>z<CR><ESC>', { silent = true })

-- Copy current file path to clipboard
map("n", "<leader>cp", [[:let @+=expand("%")<CR>]], { silent = true })

-- Open current file in GitHub
local function open_in_gh()
  local user_repo = fn.system("git config --get remote.origin.url"):match("https://github%.com/([%w%d-/]+)%.git")
  if user_repo then
    local branch = fn.system("git branch --show-current"):gsub("%s*$", "")
    local file = vim.fn.expand("%:p:~:.")
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local gh_url = "https://github.com/" .. user_repo .. "/blob/" .. branch .. "/" .. file .. "#L" .. line
    fn.system("open " .. gh_url)
  end
end
map("n", "<leader>go", open_in_gh)
