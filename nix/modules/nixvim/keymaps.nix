{ ... }: {
  programs.nixvim.keymaps = [
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
    {
      mode = "n";
      key = "<leader>v";
      action = "<cmd>set wrap!<cr>";
      options.desc = "Word wrap enable/disable";
    }
  ];
}
