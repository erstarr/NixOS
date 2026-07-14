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

FLAKE_DIR="${1:?Usage: install.sh <flake-dir> <disko-dir>}"
DISKO_DIR="${2:?Usage: install.sh <flake-dir> <disko-dir>}"


echo "Flake Dir: $FLAKE_DIR"
echo "Disko Dir:  $DISKO_DIR"

# 1. Wipe, partition, format, mount
confirm "STEP 1: Wipe, partition, format and mount disk. THIS IS DESTRUCTIVE. Continue?"
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount     "$DISKO_DIR/disko.nix"


# 2. Create an empty root vol for impermemence
confirm "STEP 2: Creating empty root-blank subvolume (read only). Continue?"
sudo btrfs subvolume snapshot -r /mnt/partition-root/root /mnt/partition-root/root-blank


# 3. Nix Install
confirm "STEP 3: Run nixos-install. Continue (It'll hang until you provide a password)?"
sudo nixos-install --flake "$FLAKE_DIR"


# 4. User Password setting - Username: redstar
confirm "STEP 4: Setting user password. Continue?"
sudo nixos-enter --root /mnt -c 'passwd redstar'


echo "install script complete. Reboot to continue to NixOS!"

