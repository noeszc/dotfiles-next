local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- Lazy
    -- {
    --   "vague2k/vague.nvim",
    --   config = function()
    --     require("vague").setup({ transparent = true, bold = false, italic = false })
    --     vim.cmd("colorscheme vague")
    --     vim.cmd(":hi statusline guibg=NONE")
    --   end,
    -- },
    {
      "webhooked/kanso.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        require("kanso").setup({
          bold = false,
          italic = false,
          commentStyle = { italic = false },
          keywordStyle = { italic = false },
        })
        vim.cmd("colorscheme kanso-ink")
        vim.cmd(":hi statusline guibg=NONE")
      end,
    },
    -- {
    --   "rose-pine/neovim",
    --   name = "rose-pine",
    --   lazy = false,
    --   priority = 1000,
    --   config = function()
    --     require("rose-pine").setup({
    --       styles = {
    --         italic = false,
    --         bold = false,
    --       },
    --     })
    --     vim.cmd.colorscheme("rose-pine")
    --   end,
    -- },
    { "SmiteshP/nvim-navic" },
    { import = "plugins" },
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = false },
  change_detection = { enabled = false },
})
