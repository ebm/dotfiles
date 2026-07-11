return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    view_options = {
      show_hidden = false,
    },
    keymaps = {
      ['<CR>'] = {
        desc = 'Open file (images go to imv)',
        callback = function()
          local oil = require 'oil'
          local entry = oil.get_cursor_entry()
          local dir = oil.get_current_dir()
          if not entry or not dir then return end

          local image_exts = { png = true, jpg = true, jpeg = true, gif = true, webp = true, bmp = true, avif = true, jxl = true }
          local ext = entry.name:match '%.([^.]+)$'

          if ext and image_exts[ext:lower()] then
            vim.fn.jobstart({ 'imv', dir .. entry.name }, { detach = true })
          else
            oil.select()
          end
        end,
      },
    },
  },
  -- Optional dependencies
  dependencies = { { 'nvim-mini/mini.icons', opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
