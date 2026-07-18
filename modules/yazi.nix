{

  # Also has an accompanying home manager module for writing a custom .desktop entry for it

  programs.yazi.enable = true;


  # This makes xdg-open calls on directories open yazi.
  xdg.mimeApps = {
    enable = true;
    defaultApplications."inode/directory" = "yazi.desktop";
  };
}

