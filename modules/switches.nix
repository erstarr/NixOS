{ lib, ... }:
{

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



  # TODO: integrate Vm specific logic to disko config too, rn it has to be done by hand
  # Switch this when on VM/BareMetal
  options.custom.virtualMachines.vmMode = lib.mkOption {
    type    = lib.types.bool;
    default = false;
    description = "Enable VM only config options. DO NOT ENABLE IF NOT IN A VM!";
  };


}