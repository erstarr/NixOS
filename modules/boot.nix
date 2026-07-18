


{
  pkgs,
  ...
}:


{
  boot = {

    kernelPackages = pkgs.linuxPackages_latest;


    # TODO - PUT THIS IN A PER-HOST FILE! ONLY ON DESKTOP SYSTEMS!
    blacklistedKernelModules = [ "iwlwifi" ]; # Disable wifi driver

    loader = {

      grub = {

        # Use the GRUB 2 boot loader.
        enable = true;

        efiSupport = true;
        # efiInstallAsRemovable = true;

        # Define on which hard drive you want to install Grub.
        device = "nodev"; # Using UEFI


        configurationLimit = 50; # Number of boot entries to keep (each rebuild switch adds a new one)
      };

      efi = {
        efiSysMountPoint = "/boot/efi"; # So that only efi files are exposed as a fat filesystem
      };

    };
  };
}
