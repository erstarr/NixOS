
{
  disko,
  lib,
  vmMode,
  ... 
}:

let
  dontPartitionRoot = vmMode && false; # vmMode is baremetal guard. flip false -> true for dev VM (single large root) --- redundant after i get a Virt Disk SSD
in
{
  imports = [ disko.nixosModules.disko ];



  disko.devices = {
    disk = {
      main = {
        device = if vmMode then "/dev/vda" else "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # EFI Boot Part
            ESP = {
              priority = 1;
              name = "ESP"; # Efi System Partition
              size = "1G";
              type = "EF00"; # Filesystem type -> EFI Boot Part
              content = {
                type = "filesystem";
                format = "vfat"; # EFI boot part wants FAT (using vFAT here. works.)
                mountpoint = "/boot/efi";
                mountOptions = [
                  "umask=0077" # Emulate perm for FAT -- only root can read/write
                ];
                extraArgs = [
                  "-n" "BOOT" # Label the boot part
                ];
              };
            };
          } // lib.optionalAttrs (!dontPartitionRoot) {
            # Virtual Disk Storage - EXT4 --- TODO when you get another SSD for just virt disks, extract this block from here
            virtdsk = {
              priority = 2;
              size = if vmMode then "1G" else "400G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/var/lib/libvirt/images";
                extraArgs = [ "-L" "virt_disk" ]; # -L sets the label for ext4/btrfs
              };
            };
          } // {
            # Root - BTRFS
            root = {
              priority = 3;
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f" # Override existing partition
                  "-L" "root_subvol" # Label subvol as root-subvol
                ];
                subvolumes = {
                  # For impermanence, Most of the subvols here are not explicitly persisted in imperm since they're already excluded from being wiped since they're their own subvolume.
                  "root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "boot" = {
                    mountpoint = "/boot";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime" # Optimisation
                    ];
                  };
                  "log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" ];
                  };
                  # NixOS sets the nodatacow atrribute on the inode itself since btrfs doesn't allow me to set it here (conflict with compress= on other subvol).
                  # nodatacow also disables compression implicitly which is important!
                  # lsattr /.swapvol/swapfile to check
                  "swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = if vmMode then "8G" else "32G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
