{ inputs, ... }: {
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";
    colorschemes.catppuccin.enable = true;
    plugins = {
      lualine.enable = true;
      telescope.enable = true;
      web-devicons.enable = true;
      treesitter.enable = true;
      oil.enable = true;
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
    ];
  };

}
