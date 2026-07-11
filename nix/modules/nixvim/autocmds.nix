{ ... }: {
  programs.nixvim.autoCmd = [
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
}
