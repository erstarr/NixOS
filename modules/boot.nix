{
  pkgs,
  ...
}:


{
  boot = {

    kernelPackages = pkgs.linuxPackages_latest;

    # pt ==> 1:1 on no passthrough (direct mapping, no isolation), full islation on passthrough (overhead). For nested virt to work devices have to be isolated in any case.
    kernelParams = [ "iommu=pt" ];

    loader = {

      grub = {

        # Use the GRUB boot loader.
        enable = true;

        efiSupport = true;
        # efiInstallAsRemovable = true;

        # Define on which hard drive you want to install Grub.
        device = "nodev"; # Using UEFI


        configurationLimit = 50; # Number of boot entries to keep (each rebuild switch adds a new one)
      };

      efi = {
        efiSysMountPoint = "/boot/efi"; # So that only efi files are exposed as a fat filesystem
        canTouchEfiVariables = true; # Necessary for EFI boot entry to be registered
      };

    };
  };
}
