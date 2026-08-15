# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  vmMode,
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

    ./modules/font_config.nix

    ./modules/packages_system.nix # common packages

    ./modules/changeOnlyOnFreshInstall.nix # first insall version

    ./modules/defaultStuff_commented.nix # Just Commented Stuff
  

    # gtk themeing shit
    ./modules/dconf.nix


    # Per app files
    ./modules/per_app/man.nix

    ./modules/per_app/hyprland.nix

  ]
  # VM Switch. Append if vmMode is true. If not, the whole .nix file won't be imported
  ++ lib.optionals (vmMode) [
    ./modules/vm_specific.nix
  ]
  ++ lib.optionals (!vmMode) [
    ./modules/ssh.nix
  ]
  ;

  # Config values live in /username/.config/NixOS_Config!
  environment.etc."nixos".source = "/home/redstar/.config/NixOS_Config";


  # Using flakes so this is dead weight
  nix.channel.enable = false;

  nix.settings.experimental-features = [
    # Enable Flakes
    "nix-command"
    "flakes"
  ];









  #MARK: vmMode insurance - detect if it's incorrectly set

  assertions =
  let
    virtioModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "virtio_mmio" ];
    hasVirtio    = builtins.any
      (m: builtins.elem m config.boot.initrd.availableKernelModules)
      virtioModules;
    foundModules = builtins.concatStringsSep " " config.boot.initrd.availableKernelModules;
  in
  [
    {
      # vmMode true but no virtio → bare-metal hardware config was used
      assertion = vmMode -> hasVirtio;
      message = ''
        vmMode = true but no virtio modules in boot.initrd.availableKernelModules.
        Found: [ ${foundModules} ]
        Hardware config looks like bare metal. Either set vmMode = false in flake.nix,
        or regenerate hardware-configuration.nix from inside the VM.
      '';
    }
    {
      # vmMode false but virtio present → VM hardware config was used on bare metal
      assertion = !vmMode -> !hasVirtio;
      message = ''
        vmMode = false but virtio modules found in boot.initrd.availableKernelModules.
        Found: [ ${foundModules} ]
        Hardware config looks like a VM. Either set vmMode = true in flake.nix,
        or regenerate hardware-configuration.nix on bare metal.
      '';
    }
  ];




}
