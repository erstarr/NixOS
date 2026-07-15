
{
  disko,
  ... 
}:


{
  imports = [ disko.nixosModules.disko ];



  disko.devices = {
    disk = {
      main = {
        device = "/dev/vda"; # TODO --> /dev/nvme0n1
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # EFI Boot Part
            ESP = {
              priority = 1;
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [
                  "umask=0077" # Emulate perm for FAT -- only root can read/write
                ];
                extraArgs = [
                   "-n BOOT" # Label the boot part
                ];
              };
            };
            # Virtual Disk Storage - EXT4
            virtdsk = {
              priority = 2;
              size = "1G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/var/lib/libvirt/images";
                extraArgs = [ "-L virt_disk" ];  # -L sets the label for ext4/btrfs
              };
            };
            # Root - BTRFS
            root = {
              priority = 3;
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f" # Override existing partition
                  "-L root_subvol" # Label subvol as root-subvol
                ];
                mountpoint = "/partition-root";
                subvolumes = {
                  # For impermanence:
                  # Empty subvolume - the initrd rollback restores root to a fresh snapshot of this on every boot ==> Created in the install script as disko doesn't have that function
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime" # Optimisation
                    ];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" ];
                  };
                  # NixOS sets the nodatacow atrribute on the inode itself since btrfs doesn't allow me to set it here (conflict with compress= on other subvol).
                  # nodatacow also disables compression implicitly which is important!
                  # lsattr /.swapvol/swapfile to check
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "8G"; # TODO --> VM; adjust to 32G on bare metal
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
