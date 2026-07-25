{ ... }: {
  programs.nixvim.opts = {
    number = true;
    relativenumber = true;
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
    cursorline = true;
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
}
