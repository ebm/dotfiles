{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      opener.edit = [
        {
          run = "nvim %s";
          desc = "nvim";
          for = "unix";
          block = true;
        }
      ];
    };

    keymap.mgr.prepend_keymap = [
      {
        on = "j";
        run = "arrow 1";
        desc = "Next file";
      }
      {
        on = "k";
        run = "arrow -1";
        desc = "Previous file";
      }
      {
        on = "<Down>";
        run = "arrow 1";
        desc = "Next file";
      }
      {
        on = "<Up>";
        run = "arrow -1";
        desc = "Previous file";
      }
    ];
  };
}
