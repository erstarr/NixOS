# If you want plugins and stuff, configure yazi through the module [system module] (would need to set settings, etc... in nix and not in .toml file)
{ config, ... }:

let
  dotDir = "${config.home.homeDirectory}/.config/NixOS_Config/dotfiles";
in
{
  # TODO MAINTENANCE: keep in sync with yazi.desktop
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

  # Yazi
  xdg.configFile."yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotDir}/yazi";

}
