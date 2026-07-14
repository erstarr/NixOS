{


  #MARK: Impermemence Filesystem Options

  # Directories that need to be mounted before init system starts writing to them - i.e. if the init system is to write to these directories, they must be mounted early
  # Is not strictly necessary for all the stuff in here to be mounted at initrd but won't hurt
  fileSystems."/persist" = {
    neededForBoot = true;
  };

  # Logs need to be written to the non-ephemeral partition
  fileSystems."/var/log" = {
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    neededForBoot = true;
  };



  # If networkmanager suff is persisted. TODO I don't know if this is done implicitly?
  # fileSystems."/var/lib" = {
  #   neededForBoot = true;
  # };






  # Using systemd for rollback

  # boot.initrd.systemd.enable = true;



  # Nix module only handler / paths
  # Home manager module does ~ paths
  














}