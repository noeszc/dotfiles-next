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
    { "lukas-reineke/indent-blankline.nvim", event = "BufReadPre", main = "ibl", opts = {} },
    { "kylechui/nvim-surround", keys = { "cs", "ds", "ys" }, opts = {} },
    { "windwp/nvim-autopairs", event = "InsertEnter", opts = { check_ts = true } },
    { "windwp/nvim-ts-autotag", event = "InsertEnter", opts = {} },
    { import = "plugins" },
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = false },
  change_detection = { enabled = false },
})
