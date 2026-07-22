{ lib, ... }:
{


  #MARK: IMPORTANT!!
  #########################################################################################################
  ###############################################################################################
  ####################################################################################
  ####### vmMode switch is in flake.nix!!! MUST NOT TURN THAT ON ON BAREMETAL!
  ####################################################################################
  ###############################################################################################
  #########################################################################################################
  #MARK: IMPORTANT!!

  config.custom.impermanence.entireHomeDirImpermanence = false;

  config.custom.hyprland.useFlake = true;





  # Persist the entire /home. Disables home manager's home persistence stuff.
  options.custom.impermanence.entireHomeDirImpermanence = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Persist entire home dir. False = selective persistence.";
  };



  # Use hyprland as a flake or follow nix-unstable (or whatever pkg source i have in flake.nix)
  options.custom.hyprland.useFlake = lib.mkOption {
    type    = lib.types.bool;
    default = true;
    description = "Use Hyprland flake input (with its pinned mesa) instead of nixpkgs.";
  };



}