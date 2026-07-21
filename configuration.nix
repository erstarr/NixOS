# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./modules/hardware.nix

    ./modules/btrfs.nix

    ./modules/boot.nix

    ./modules/power.nix

    ./modules/systemd.nix

    ./modules/nixStore.nix

    ./modules/swap.nix

    ./modules/snapshot.nix

    ./modules/virtualisation.nix

    ./modules/networking.nix
    ./modules/firewall.nix

    ./modules/timeAndLocale.nix

    ./modules/sound.nix

    ./modules/userAccounts.nix

    ./modules/x11.nix

    ./modules/defaultPrograms.nix

    ./modules/packages_system.nix # common packages

    ./modules/changeOnlyOnFreshInstall.nix # first insall version

    ./modules/defaultStuff_commented.nix # Just Commented Stuff
  

    # gtk themeing shit
    ./modules/dconf.nix


    # Per app files
    ./modules/per_app_config/man.nix

    ./modules/per_app_config/hyprland.nix


    # Various toggleable switches
    ./modules/switches.nix

  ]
  # VM Switch. Append if vmMode is true. If not, the whole .nix file won't be imported
  ++ lib.optionals (config.custom.virtualMachines) [
    ./modules/vm_specific.nix
  ]
  ++ lib.optionals (!config.custom.virtualMachines) [
    ./modules/ssh.nix
  ]
  ;

  # Config values live in /username/NixOS_Config!
  environment.etc."nixos".source = "/home/redstar/NixOS_Config";

  nix.settings.experimental-features = [
    # Enable Flakes
    "nix-command"
    "flakes"
  ];

}
