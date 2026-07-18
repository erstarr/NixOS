{
  # TODO: keep in sync with yazi.desktop
  xdg.desktopEntries.yazi = {
    name = "Yazi File Manager";
    icon = "yazi";
    comment = "Blazing fast terminal file manager written in Rust, based on async I/O";
    terminal = false; # Edited
    exec = "kitty --detach yazi %u"; # Edited
    type = "Application";
    mimeType = [ "inode/directory" ];
    categories = [
      "System"
      "FileManager"
      "FileTools"
      "ConsoleOnly"
    ];
    settings = {
      TryExec = "yazi";
      Keywords = "File;Manager;Explorer;Browser;Launcher";
    };
  };
}
