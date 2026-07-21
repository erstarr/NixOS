# Putting em all here now - if you wanna do fancy stuff with any, extract it into its own .nix file
{ config, ... }:

let
  dotDir = "NixOS_Config/dotfiles";
in {

  # Hyprland
  xdg.configFile."hypr".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/${dotDir}/hypr";

  # Waybar
  xdg.configFile."waybar".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/${dotDir}/waybar";

  # rofi
  xdg.configFile."rofi".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/${dotDir}/rofi";


  # SwayNC
  xdg.configFile."swaync".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/${dotDir}/swaync";

  # Satty
  xdg.configFile."satty".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/${dotDir}/satty";


  # Yazi
  xdg.configFile."yazi".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/${dotDir}/yazi";


  # home.file.".somerc".source =
  #   config.lib.file.mkOutOfStoreSymlink
  #     "${config.home.homeDirectory}/NixOS_Config/dotfiles/somerc";
}