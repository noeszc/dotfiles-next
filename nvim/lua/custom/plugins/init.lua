-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'e-q/okcolors.nvim',
    config = function()
      vim.cmd 'colorscheme okcolors'
    end,
  },
}
