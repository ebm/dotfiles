{
  programs.btop = {
    enable = true;
    settings = {
      save_config_on_exit = false;

      theme_background = false;
      vim_keys = true;
      shown_boxes = "proc cpu mem";
      proc_gradient = false;
    };
  };
}
