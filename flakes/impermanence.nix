
{
  config,
  lib,
  impermanence,
  ...
}:

{


  ###################################################################################################################################
  ###################################################################################################################################
  # This operates PER-SUBVOLUME! If a subvolume isn't reset explicitly, it is not a part of Impermanence at all and is NOT TOUCHED! #
  ###################################################################################################################################
  ###################################################################################################################################


  imports = [ impermanence.nixosModules.impermanence ];


  options.custom.impermanence.homeImpermanence = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable home impermanence";
  };

  # to override (change val) use config. prefix instead of option.: config.custom.impermanence.homeImpermanence = false;

  #MARK: Impermemence Filesystem Options
  config = {  # required when mixing options + config in same file
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

    # If homeImpermanence is enabled, early mount it as well
    fileSystems."/home" = {
      neededForBoot = config.custom.impermanence.homeImpermanence;
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
        # What else to be persisted goes here
        # { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
      ]
      # If home imperm is enabled,
      ++ lib.optionals config.custom.impermanence.homeImpermanence [
          "/home/redstar"
          # "/home/whatever"
        ];
      
      files = [
        "/etc/machine-id"
        # { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
      ];
    };

    # Avoid sudo lecture first-time usage message:
      security.sudo.extraConfig = ''
        Defaults lecture = never
      '';


    boot.initrd.systemd.services.impermanence = {

      description = "Ephemeral root rollback";
      wantedBy = ["initrd.target"];
      after = ["initrd-root-device.target"];
      before = ["sysroot.mount"];
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
          for i in $(find /btrfs_tmp/persist/old_roots/ -mindepth 1 -maxdepth 1 -mtime +$max_age); do
            btrfs subvolume delete --recursive "$i"
          done
        fi

        # Create a fresh root
        btrfs subvolume create /btrfs_tmp/root

        # Home impermanence (Optional - can disable with the switch) - rollback
        ${lib.optionalString config.custom.impermanence.homeImpermanence ''
          
          # Move old home to /persist/old_homes
          if [[ -e /btrfs_tmp/home ]]; then
            mkdir -p /btrfs_tmp/persist/old_homes
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/home)" "+%Y-%m-%d_%H:%M:%S")
            mv /btrfs_tmp/home "/btrfs_tmp/persist/old_homes/$timestamp"
          fi

          # Remove old homes periodically.
          max_age=30  # days until removed
          # Make sure dir exists guard
          if [[ -d /btrfs_tmp/persist/old_homes ]]; then
            for i in $(find /btrfs_tmp/persist/old_homes/ -mindepth 1 -maxdepth 1 -mtime +$max_age); do
              btrfs subvolume delete --recursive "$i"
            done
          fi

          # Create a fresh home.
          btrfs subvolume create /btrfs_tmp/home
        ''}

        umount /btrfs_tmp
      '';

    };
    
  };


  # If networkmanager suff is persisted. TODO I don't know if this is done implicitly?
  # fileSystems."/var/lib" = {
  #   neededForBoot = true;
  # };



  # Using systemd for rollback


  # Nix module only handler / paths
  # Home manager module does ~ paths
  










}