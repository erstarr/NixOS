# using snapper
# Snapshots are in .snapshots inside the dir they are snapshotting; which means they survive imperm if the dir they're snapshotting survives



{

  # After https://github.com/NixOS/nixpkgs/pull/368449 is merged, this is redundant
  systemd.tmpfiles.rules = [
    "v /persist/.snapshots  0750 root root -" # v type creates a btrfs subvolume only when the root directory / is itself a btrfs subvolume
    # "v /var/log/.snapshots  0750 root root -"

    # Excluded Dirs (the way to do this in snapper at least as of july 2026 is to make them a btrfs subvolume)
    "v /persist/home/redstar/Downloads        0755 redstar redstar -"
    "v /persist/home/redstar/Videos           0755 redstar redstar -"
  ];



    services.snapper = {
    persistentTimer = true; # Create snapshot asap if the last interval was missed (i.e. it will snapshot once on every boot at least)

    configs = {
      persist = {
        SUBVOLUME = "/persist";
        FSTYPE = "btrfs";
        ALLOW_USERS = [ "redstar" ];
        TIMELINE_CREATE  = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY    = 12;
        TIMELINE_LIMIT_DAILY     = 7;
        TIMELINE_LIMIT_WEEKLY    = 4;
        TIMELINE_LIMIT_MONTHLY   = 3;
        TIMELINE_LIMIT_QUARTERLY = 0;
        TIMELINE_LIMIT_YEARLY    = 0;
      };

      # log = {
      #   SUBVOLUME = "/var/log";
      #   FSTYPE = "btrfs";
      #   ALLOW_USERS = [ "redstar" ];
      #   TIMELINE_CREATE  = true;
      #   TIMELINE_CLEANUP = true;
      #   TIMELINE_LIMIT_HOURLY    = 0;
      #   TIMELINE_LIMIT_DAILY     = 2;
      #   TIMELINE_LIMIT_WEEKLY    = 2;
      #   TIMELINE_LIMIT_MONTHLY   = 2;
      #   TIMELINE_LIMIT_QUARTERLY = 0;
      #   TIMELINE_LIMIT_YEARLY    = 0;
      # };
    };
  };
}