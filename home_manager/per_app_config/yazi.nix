{
  xdg.desktopEntries.yazi = {
    name = "Yazi File Manager";
    icon = "yazi";
    comment = "Blazing fast terminal file manager written in Rust, based on async I/O";
    terminal = true;
    exec = "yazi %f";
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
