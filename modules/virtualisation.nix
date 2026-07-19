{ pkgs, ... }:


# NOT PRACTICALY TO MAKE EVERYTHING DECLERATIVE - CHECK NOTES FOR FIRST INSTALL STEPS

# Nested Virt should work by default

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu; # TODO:  CHANGE TO qemu_full AFTER CEPH DEP IS FIXED!    # equivalent of qemu-full on Arch
      runAsRoot = true;
      swtpm.enable = true;         # swtpm
    };
  };



  # TODO - not sure if the libvirt nix package correctly manages radvd path being different, so i do this to be certain. If it does, remove this! 
  # radvd available to libvirtd for IPv6 RA per-network
  # libvirt spawns its own per-network radvd instance when IPv6 is configured on a network
  # Do NOT enable services.radvd alongside this -- two instances on the same interface conflict
  systemd.services.libvirtd.path = [ pkgs.radvd ];




  security.polkit.enable = true;

  # Virtual Machine Manager
  programs.virt-manager.enable = true;


  # for passthrough
  boot.kernelParams = [ "iommu=pt" ];
  # boot.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];

}