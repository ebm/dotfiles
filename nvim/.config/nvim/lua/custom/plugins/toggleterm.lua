return {
  'akinsho/toggleterm.nvim',
  config = function()
    require('toggleterm').setup {
      open_mapping = [[<C-\>]], -- press Ctrl+\ to toggle
      direction = 'float', -- or "horizontal" / "vertical"
    }
  end,
}
