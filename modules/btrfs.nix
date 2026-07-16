{

  # integrity checks
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ]; # only top level of physical pertitions is enough
  };


  # TODO set up snapshots

}