# using snapper
# Snapshots are in .snapshots inside the dir they are snapshotting; which means they survive imperm if the dir they're snapshotting survives

# Excluding dirs - make the /persist/... path a btrfs subvolume. Doing this post first install is a pain. Can create a systemd oneshot for this maybe

{pkgs, ...}:

let
  snapshotExcludedDirs = [
    { path = "/persist/home/redstar/Downloads"; mode = "0755"; owner = "redstar:redstar"; }
    { path = "/persist/home/redstar/Videos";    mode = "0755"; owner = "redstar:redstar"; }
    # old roots and homes from imperm are their own subvols so they are excluded
  ];
in
{

  # After https://github.com/NixOS/nixpkgs/pull/368449 is merged, this is redundant
  systemd.tmpfiles.rules = [
    "v /persist/.snapshots  0750 root root -" # v type creates a btrfs subvolume only when the root directory / is itself a btrfs subvolume
    # "v /var/log/.snapshots  0750 root root -"

  ];



    # If dir doesn't exist, create the dir and btrfs subvolume it
    # If dir already exists, make it a btrfs subvol by moving the contents, making the subvol and copying them back
    # Then fix permissions
    systemd.services.btrfs-ensure-snapshot-exclusions = {
      description = "Ensure snapper-excluded dirs are btrfs subvolumes";
      wantedBy    = [ "multi-user.target" ];
      after       = [ "local-fs.target" ];
      before      = [ "snapper-timeline.service" "snapper-cleanup.service" "snapperd.service" ];
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
      path   = [ pkgs.btrfs-progs pkgs.coreutils ];
      script = ''

        set -euo pipefail

        ensure_subvol() {
          local dir=$1 mode=$2 owner=$3
          btrfs subvolume show "$dir" &>/dev/null && return 0
          if [[ -d "$dir" ]]; then
            tmp="$dir.__conv_$$"
            mv "$dir" "$tmp"
            btrfs subvolume create "$dir"
            cp -a "$tmp/." "$dir/"
            rm -rf "$tmp"
          else
            mkdir -p "$(dirname "$dir")"
            btrfs subvolume create "$dir"
          fi
          # The dir was created as root:root by btrfs so we need to fix that - the contents of the files's permissions/ownerships should have been preserved by cp -a
          chmod "$mode" "$dir"
          chown "$owner" "$dir"
        }

        ${builtins.concatStringsSep "\n"
            (map (d: ''ensure_subvol "${d.path}" "${d.mode}" "${d.owner}"'') snapshotExcludedDirs)}
      '';
    };


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