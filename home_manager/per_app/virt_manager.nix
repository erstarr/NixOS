{

  # Virt-Manager is enabled/installed elsewhere

  dconf.settings = {

    # Virt-Manager settings
    "org/virt-manager/virt-manager" = {
      xmleditor-enabled = true;
    };
    "org/virt-manager/virt-manager/stats" = {
      enable-disk-poll = true;
      enable-net-poll = true;
      enable-memory-poll = true;
    };
    "org/virt-manager/virt-manager/console" = {
      resize-guest = 1;
      grab-keys = "65507,65513";
      auto-redirect = false;
    };
    "org/virt-manager/virt-manager/confirm" = {
      poweroff = true;
      pause = true;
    };
    "org/virt-manager/virt-manager/vmlist-fields" = {
      host-cpu-usage = true;
      memory-usage = true;
      disk-usage = true;
      network-traffic = true;

    };
  };
}
