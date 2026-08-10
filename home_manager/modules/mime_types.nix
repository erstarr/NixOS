{ ... }:

{

  xdg.mimeApps = {
    enable = true;

    # This makes xdg-open calls on directories open yazi.
    defaultApplications = {

      "inode/directory" = "yazi.desktop";
      "application/pdf" = "org.mozilla.firefox.desktop";
      "video/mp4" = "org.mozilla.firefox.desktop";

    };

  };

}
