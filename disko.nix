{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/vda"; # /dev/nvme0n1
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # EFI Boot Part
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M"; # for GPT header
              end = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [ "umask=0077" ];
              };
            };
            # Root - BTRFS
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos" # Explicit labeling
                  "-f" # Override existing partition
                ];
                mountpoint = "/partition-root";
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                    ];
                  };
                  # For impermanence:
                  # Empty subvolume - the initrd rollback restores root to a fresh snapshot of this on every boot ==> Created in the install script as disko doesn't have that function
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime" # Optimisation
                    ];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                    ];
                  };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "8G"; # VM; adjust to 32G on bare metal
                  };
                };
              };
            };
          };
        };
      };
      libvirt = {
        device = "/dev/vdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            images = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/var/lib/libvirt/images";
              };
            };
          };
        };
      };
    };
  };
}
