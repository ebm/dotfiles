{ inputs, ... }: {
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";
    colorschemes.catppuccin.enable = true;
    plugins = {
      lualine = {
        enable = true;
        settings = {
          options = {
            theme = "auto";
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
                    if name == "" then return "[No Name]" end
                    return vim.fn.fnamemodify(name, ":~:.")
                  end
                '';
              }
            ];
          };
        };
      };
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
      neoscroll.enable = true;
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
    diagnostics = {
      virtual_text = true;
    };
    opts = {
      number = true;
      breakindent = true;
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      updatetime = 1000;
      splitright = true;
      splitbelow = true;
      list = true;
      listchars = {
        tab = "» ";
        trail = "·";
        nbsp = "␣";
      };
      inccommand = "split";
      scrolloff = 100;
      linebreak = true;
      wrap = false;
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>sf";
        action = "<cmd>Telescope find_files<cr>";
      }
      {
        mode = "n";
        key = "-";
        action = "<cmd>Oil<cr>";
      }
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>lua require('conform').format({ async = true, lsp_format = 'fallback'})<cr>";
      }
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<cr>";
      }
      {
        mode = "n";
        key = "<leader>q";
        action.__raw = "vim.diagnostic.setloclist";
        options.desc = "Open diagnostic quickfix list";
      }
      {
        mode = "t";
        key = "<Esc><Esc>";
        action = "<C-\\><C-n>";
        options.desc = "Exit terminal mode";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w><C-h>";
        options.desc = "Move focus to the left window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w><C-j>";
        options.desc = "Move focus to the lower window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w><C-k>";
        options.desc = "Move focus to the upper window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w><C-l>";
        options.desc = "Move focus to the right window";
      }
      {
        mode = "n";
        key = "j";
        action = "gj";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "k";
        action = "gk";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>th";
        action.__raw = ''
          function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
          end
        '';
        options.desc = "Toggle Inlay Hints";
      }
      {
        mode = "n";
        key = "<leader>sF";
        action.__raw = ''
          function()
            require('telescope.builtin').find_files({ hidden = true, no_ignore = true })
          end
        '';
        options.desc = "Find files (incl. hidden + ignored)";
      }
      {
        mode = "n";
        key = "<leader>sg";
        action = "<cmd>Telescope live_grep<cr>";
        options.desc = "Search by Grep";
      }
      {
        mode = "n";
        key = "<leader>sG";
        action.__raw = ''
          function()
            require('telescope.builtin').live_grep({ hidden = true, no_ignore = true })
          end
        '';
        options.desc = "Search by Grep (incl. hidden + ignored)";
      }
      {
        mode = "n";
        key = "<leader><leader>";
        action = "<cmd>Telescope buffers<cr>";
        options.desc = "Find existing buffers";
      }
    ];
    autoCmd = [
      {
        event = [ "TextYankPost" ];
        desc = "Highlight when yanking (copying) text";
        callback.__raw = ''
          function()
            vim.hl.on_yank()
          end
        '';
      }
      {
        event = [ "LspAttach" ];
        desc = "Set up LSP document highlight on cursor hold";
        callback.__raw = ''
          function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if not client then return end
            if not client:supports_method('textDocument/documentHighlight', event.buf) then return end
            local group = vim.api.nvim_create_augroup('user-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('user-lsp-detach', { clear = true }),
              callback = function(ev)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = 'user-lsp-highlight', buffer = ev.buf })
              end,
            })
          end
        '';
      }
    ];
  };

}
