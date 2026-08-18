{ pkgs, ... }:


# NOT PRACTICALY TO MAKE EVERYTHING DECLERATIVE - CHECK NOTES FOR FIRST INSTALL STEPS

# Nested Virt should work by default

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu; # TODO TEMPORARY:  CHANGE TO qemu_full AFTER CEPH DEP IS FIXED! ==> qemu is almost everything while wemu_full IS everything (if you need the extras is questionable)
      runAsRoot = true;
      swtpm.enable = true;         # swtpm
    };
  };

  # Nested Virtualisation - Enabled by default
  # boot.extraModprobeConfig = "options kvm_amd nested=1";




  # TODO - not sure if the libvirt nix package correctly manages radvd path being different, so i do this to be certain. If it does, remove this! 
  # radvd available to libvirtd for IPv6 RA per-network
  # libvirt spawns its own per-network radvd instance when IPv6 is configured on a network
  # Do NOT enable services.radvd alongside this -- two instances on the same interface conflict
  systemd.services.libvirtd.path = [ pkgs.radvd ];




  security.polkit.enable = true;

  # Virtual Machine Manager - configuration done in home manager
  programs.virt-manager.enable = true;


  # for passthrough
  # IOMMU is set in boot.nix
  # boot.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];


  # Networking


  # Default Switch - Allow Internet Access
  # 53 -> libvirt's dnsmasq
  # 67 -> DHCP
  networking.firewall.extraInputRules = ''
  iifname "virbr0" udp dport { 53, 67 } accept
  iifname "virbr0" tcp dport 53 accept
  '';




}