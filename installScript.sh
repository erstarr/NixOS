#!/usr/bin/env bash



confirm() {
    local msg="$1"
    read -rp "$msg [y/N] " ans
    case "$ans" in
        [yY]) return 0 ;;
        *) echo "Aborted."; exit 1 ;;
    esac
}

# Failiure Mode
set -euo pipefail
# Write an install log
exec > >(tee /tmp/install.log) 2>&1

FLAKE_DIR="${1:?Usage: install.sh <flake-dir> <disko-dir> <hostname>}"
DISKO_DIR="${2:?Usage: install.sh <flake-dir> <disko-dir> <hostname>}"
HOSTNAME="${3:?Usage: install.sh <flake-dir> <disko-dir> <hostname>}"

echo "Flake Dir: $FLAKE_DIR"
echo "Disko Dir:  $DISKO_DIR"
echo "Host Name:  $HOSTNAME"

# 1. Wipe, partition, format, mount
confirm "STEP 1: Wipe, partition, format and mount disk. THIS IS DESTRUCTIVE. Continue?"
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount     "$DISKO_DIR/disko.nix"


# 2. Create an empty root vol for impermemence
confirm "STEP 2: Creating empty root-blank subvolume (read only). Continue?"
sudo btrfs subvolume snapshot -r /mnt/partition-root/root /mnt/partition-root/root-blank


# 2.5 Create hardwareConfigurations file and copy it over
confirm "STEP 2.5: Generate hardware configuration. Continue?"

# --no-filesystems because disko owns that
# gen the hardware config, write it to current config dir
sudo nixos-generate-config --root /mnt --no-filesystems --show-hardware-config > "$FLAKE_DIR/hardware-configuration.nix"
  
# 3. Nix Install
confirm "STEP 3: Run nixos-install. Continue (It'll hang until you provide a password)?"
# Explicitly use path not git since i don't want my hardware conf file to be tracked
sudo nixos-install --flake "path:${FLAKE_DIR}#${HOSTNAME}"

# 4. User Password setting - Username: redstar
confirm "STEP 4: Setting user password. Continue?"
sudo nixos-enter --root /mnt -c 'passwd redstar'


echo "install script complete. Reboot to continue to NixOS!"

