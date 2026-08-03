{ ... }: {
  programs.nixvim.plugins = {
    lualine = {
      enable = true;
      settings = {
        options = {
          globalstatus = true;
          section_separators = {
            left = "";
            right = "";
          };
          component_separators = {
            left = "";
            right = "";
          };
        };
        sections = {
          lualine_a.__raw = "{}";
          lualine_y = [
            "progress"
            { __unkeyed-1.__raw = ''function() return vim.fn.line(".") .. ":" .. vim.fn.col(".") end''; }
          ];
          lualine_z.__raw = "{}";
          lualine_c = [
            {
              __raw = ''
                function()
                  local name = vim.api.nvim_buf_get_name(0)
                  local oil = name:match("^oil://(.*)")
                  if oil then return vim.fn.fnamemodify(oil, ":~") end
                  if vim.bo.buftype == "terminal" then
                    return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
                  end
                  if name == "" then return "[No Name]" end
                  return vim.fn.fnamemodify(name, ":~:.")
                end
              '';
            }
          ];
        };
      };
    };
    which-key.enable = true;
    telescope.enable = true;
    web-devicons.enable = true;
    treesitter.enable = true;
    oil = {
      enable = true;
      settings = {
        view_options = {
          show_hidden = false;
        };
        keymaps = {
          "<CR>" = {
            desc = "Open file (images go to imv)";
            callback.__raw = ''
              function()
                local oil = require('oil')
                local entry = oil.get_cursor_entry()
                local dir = oil.get_current_dir()
                if not entry or not dir then return end
                local image_exts = { png = true, jpg = true, jpeg = true, gif = true, webp = true, bmp = true, avif = true, jxl = true }
                local ext = entry.name:match('%.([^.]+)$')
                if ext and image_exts[ext:lower()] then
                  vim.fn.jobstart({ 'imv', dir .. entry.name }, { detach = true })
                else
                  oil.select()
                end
              end
            '';
          };
        };
      };
    };
    nvim-autopairs.enable = true;
    blink-cmp.enable = true;
    conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
          python = [ "black" ];
        };
      };
    };
    gitsigns.enable = true;
    markview.enable = true;
    # neoscroll.enable = true;
    toggleterm = {
      enable = true;
      settings = {
        open_mapping = "[[<C-\\>]]";
        direction = "float";
      };
    };
    lsp = {
      enable = true;
      servers = {
        lua_ls.enable = true;
        pyright.enable = true;
        clangd.enable = true;
        jdtls.enable = true;
        nixd.enable = true;
      };
      keymaps = {
        "gd" = "definition";
        "gr" = "references";
        "K" = "hover";
        "grn" = "rename";
        "gra" = "code_action";
        "grD" = "declaration";
      };
    };
    fidget.enable = true;
  };
}
