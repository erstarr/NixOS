{ config, ... }:

let
  dotDir = "NixOS_Config/dotfiles";
in {

  # history and copied images/files are wiped per boot due to impermanence


  # Scripts
  xdg.configFile."clipse/scripts".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/${dotDir}/clipse/scripts";



  # config
  xdg.configFile."clipse/config.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/${dotDir}/clipse/config.json";


  # custom_theme
  xdg.configFile."clipse/custom_theme.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/${dotDir}/clipse/custom_theme.json";


}