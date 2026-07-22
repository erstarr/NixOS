{
  config,
  lib,
  pkgs,
  impermanence,
  ...
}:

{

  ###################################################################################################################################
  ###################################################################################################################################
  # This operates PER-SUBVOLUME! If a subvolume isn't reset explicitly, it is not a part of Impermanence at all and is NOT TOUCHED! #
  ###################################################################################################################################
  ###################################################################################################################################


  ######################
  # IMPORTANT: ADDING STUFF TO PERSISTANCE PAST FIRST INSTALL REQUIRES THE MANUAL COPYING OF THE FILES PRESENT THERE IF THE CURRENT STATE MUST BE SAVED!
  ####> sudo cp -a to preserve owner,group,perms
  ######################


  # Setup: Root is always wiped - subvolumes are not touched, and from the dirs/files that are touched some are explicitly persisted.
  #        Home is always wiped. If entireHomeDirImpermanence = true, the entire home dir is persisted (it's in separate subvol so its imperm is done explicitly in script).
  #                              If entireHomeDirImpermanence = false, only some dirs/files are persisted in home.

  # Using systemd for rollback

  imports = [ impermanence.nixosModules.impermanence ];


  # to override (change val) use config. prefix instead of option.: config.custom.impermanence.entireHomeDirImpermanence = false;

  #MARK: Impermemence Filesystem Options
  config = {
    # required when mixing options + config in same file
    # Directories that need to be mounted before init system starts writing to them - i.e. if the init system is to write to these directories, they must be mounted early
    # Is not strictly necessary for all the stuff in here to be mounted at initrd but won't hurt - If a subvol isn't wiped (wiping / doesn't wipe /boot if /boot is its own subvol!)


    # Redundant really since it't a subvol that's not wiped
    fileSystems."/var/log" = {
      neededForBoot = true;
    };

    # Redundant really since it't a subvol that's not wiped
    fileSystems."/nix" = {
      neededForBoot = true;
    };


    # Redundant really since it't a subvol that's not wiped
    fileSystems."/boot" = {
      neededForBoot = true;
    };

    # Swap need not be early mounted



    # Must be early mounted so bind mounts can be set up
    fileSystems."/persist" = {
      neededForBoot = true;
    };


    # Needs to always early mount since it's always ephemeral now (always wiped, the only diff is what comes back)
    fileSystems."/home" = {
      neededForBoot = true;
    };


    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true; # Bind mount instead of symlink

      allowTrash = true; # When smt in unpersisted, it goes here. Comment out after persistence works well.

      # ONLY include stuff that Impermanence actually effects. Otherwise you'll shadow it!
      directories = [
        "/var/lib/nixos" # Mandatory
        # "/var/log" # Persisted cuz it's a btrfs subvolume
        "/etc/NetworkManager/system-connections" # Keep Connection Profiles (might symlink this from my config)
        
        # Flatpak install dir
        "/var/lib/flatpak"

        # Libvirt stuff. Virtual Disks are in their own partition so they will mount over the imperm mount and shadow it; which is ok.
        "/var/lib/libvirt"

        # { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
      ]
      # If persisting the entire home dir,
      ++ lib.optionals config.custom.impermanence.entireHomeDirImpermanence [
        "/home/redstar"
      ];
      files = [

        ######################
        # IMPORTANT: Imperm ceates a dandling symlink for files that don't exist in /persist but are persisted. If the program unlinks and then creates over it, it'll be lost next boot and you must sudo cp -a it to /persist
        # manually
        ######################

        
        "/etc/machine-id" # In first boot after install, this needs to be moved into /persist which is done by the install script

        # systemd credentials storage - libvirt uses this
        "/var/lib/systemd/credential.secret"

        # { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
      ];
    };

    # Avoid sudo lecture first-time usage message:
    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';


    # For diffing old and new-old home in the script
    boot.initrd.systemd.extraBin.comm = "${pkgs.coreutils}/bin/comm";
    boot.initrd.systemd.extraBin.sed  = "${pkgs.gnused}/bin/sed";

    boot.initrd.systemd.services.impermanence = {

      description = "Ephemeral root and home rollback";
      wantedBy = [ "initrd.target" ];
      after = [ "initrd-root-device.target" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";

      script = ''
        set -euo pipefail # exit if the script is not fine.

        mkdir -p /btrfs_tmp

        # by label: root part is labelled as root_subvol
        # root btrfs subvolume (the one that contains every other subvol).
        mount /dev/disk/by-label/root_subvol /btrfs_tmp -o subvol=/ 

        # Root Impermanence - rollback
        # Move the old root to /persist/old_roots
        if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/persist/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/persist/old_roots/$timestamp"
        fi

        # Remove old roots periodically.
        max_age=30  # days until removed
        # Make sure dir exists guard
        if [[ -d /btrfs_tmp/persist/old_roots ]]; then
          for i in $(find /btrfs_tmp/persist/old_roots/ -mindepth 1 -maxdepth 1 -type d -mtime +$max_age); do
            btrfs subvolume delete --recursive "$i"
          done
        fi

        # Create a fresh root
        btrfs subvolume create /btrfs_tmp/root



        # Diff current home against the most recently saved old home before rolling over -- only file/dir presence/absence.
        if [[ -e /btrfs_tmp/home ]] && [[ -d /btrfs_tmp/persist/old_homes ]]; then
          # Don't take down the entire script - if diffing fails, still try to home imperm
          (
            prev_home=$(find /btrfs_tmp/persist/old_homes -mindepth 1 -maxdepth 1 -type d | sort | tail -1)
            if [[ -n "$prev_home" ]]; then
              prev_ts=$(basename "$prev_home")
              curr_ts=$(date --date="@$(stat -c %Y /btrfs_tmp/home)" "+%Y-%m-%d_%H:%M:%S")

              find "$prev_home"    -mindepth 1 | sed "s|''${prev_home}/||"    | sort > /tmp/hl_old.txt
              find /btrfs_tmp/home -mindepth 1 | sed 's|/btrfs_tmp/home/||' | sort > /tmp/hl_new.txt

              only_in_old=$(comm -23 /tmp/hl_old.txt /tmp/hl_new.txt)
              only_in_new=$(comm -13 /tmp/hl_old.txt /tmp/hl_new.txt)
              rm -f /tmp/hl_old.txt /tmp/hl_new.txt

              if [[ -n "$only_in_old" ]] || [[ -n "$only_in_new" ]]; then
                {
                  printf 'Diff: %s  ->  %s\n\n' "$prev_ts" "$curr_ts"
                  if [[ -n "$only_in_old" ]]; then
                    printf '=== Only in old (%s) ===\n' "$prev_ts"
                    printf '%s\n' "$only_in_old"
                    printf '\n'
                  fi
                  if [[ -n "$only_in_new" ]]; then
                    printf '=== Only in new (%s) ===\n' "$curr_ts"
                    printf '%s\n' "$only_in_new"
                  fi
                } > "/btrfs_tmp/persist/old_homes/''${prev_ts}->''${curr_ts}_diff.txt"
              fi
            fi
          ) || echo "impermanence: diff block failed, skipping diff" > /dev/kmsg
        fi



        # Home impermanence - rollback
          
        # Move old home to /persist/old_homes
        if [[ -e /btrfs_tmp/home ]]; then
          mkdir -p /btrfs_tmp/persist/old_homes
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/home)" "+%Y-%m-%d_%H:%M:%S")
          mv /btrfs_tmp/home "/btrfs_tmp/persist/old_homes/$timestamp"
        fi


        # Remove old homes and their associated diff files periodically.
        max_age=30
        if [[ -d /btrfs_tmp/persist/old_homes ]]; then
          for i in $(find /btrfs_tmp/persist/old_homes/ -mindepth 1 -maxdepth 1 -type d -mtime +$max_age); do
            ts=$(basename "$i")
            find /btrfs_tmp/persist/old_homes/ -maxdepth 1 -name "''${ts}->*_diff.txt" -delete
            btrfs subvolume delete --recursive "$i"
          done
        fi


        # Create a fresh home.
        btrfs subvolume create /btrfs_tmp/home

        umount /btrfs_tmp
      '';

    };

  };

  # If networkmanager suff is persisted. TODO I don't know if this is done implicitly?
  # fileSystems."/var/lib" = {
  #   neededForBoot = true;
  # };

}
