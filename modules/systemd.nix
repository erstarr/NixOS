
{


  boot.initrd.systemd.enable = true;







  # Libvirt

  # libvirt - socket only
  # systemd.services.libvirtd.enable = false;
  # systemd.sockets.libvirtd.enable = true;
  # systemd.sockets.libvirtd-admin.enable = true;

  # Arch parity - enable this socket too
  # systemd.sockets.virtlogd.enable = true;
  systemd.sockets.virtlogd-admin.enable = true;


  # auto-restore VMs on host reboot - socket only
  # systemd.sockets.libvirt-guests.enable = false;
  # systemd.services.libvirt-guests.enable = false;



  # Arch has this disabled, NixOS enables it
  # systemd.sockets.virtlockd.enabled = false;





  # OOM

  # systemd's OOM stuff - is disabled on arch but enabled on nix by default -- i'll leave it enabled on nix for now
  # systemd-oomd.service = false;

  
  # Redundant stuff


}