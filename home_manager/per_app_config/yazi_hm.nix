{config, ...}:

let
  dotDir = "NixOS_Config/dotfiles";
in
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

  # This makes xdg-open calls on directories open yazi.
  xdg.mimeApps = {
    enable = true;
    defaultApplications."inode/directory" = "yazi.desktop";
  };



  # Yazi
  xdg.configFile."yazi".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${dotDir}/yazi";



}
