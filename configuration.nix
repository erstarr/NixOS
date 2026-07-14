# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  vmMode,
  ...
}:




{


  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./modules/boot.nix

    ./modules/hardware.nix

    ./modules/swap.nix
    
    ./modules/impermanence.nix

    ./modules/networking.nix
    ./modules/firewall.nix

    ./modules/timeAndLocale.nix
    
    ./modules/sound.nix
    
    ./modules/userAccounts.nix
    
    ./modules/x11.nix
    
    ./modules/defaultPrograms.nix

    ./modules/packages_system.nix       # common packages
    


    ./modules/changeOnlyOnFreshInstall.nix   # first insall version


    # ./modules/defaultStuff_commented.nix # Just Commented Stuff

  ]
  # VM Switch. Append if vmMode is true. If not, the whole .nix file won't be imported
  ++ lib.optionals vmMode [ ./modules/vm_specific.nix ];

}
