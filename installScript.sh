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

FLAKE_PATH="${1:?Usage: install.sh <path-to-flake>#<hostname>}"

echo "Flake Path: $FLAKE_PATH"
echo "Disko Config Path: $(dirname "$0")/disko.nix"

confirm "STEP 1: Wipe, partition, format and mount disk. THIS IS DESTRUCTIVE. Continue?"

# 1. Wipe, partition, format, mount
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount     "$(dirname "$0")/disko.nix"


confirm "STEP 2: Creating empty root-blank subvolume (read only). Continue?"

# 2. Create an empty root vol for impermemence
btrfs subvolume snapshot -r /mnt/partition-root/root /mnt/partition-root/root-blank

confirm "STEP 3: Run nixos-install. Continue (It'll hang until you provide a password)?"
nixos-install --flake "$FLAKE_PATH"


confirm "STEP 4: Setting user password. Continue?"

nixos-enter --root /mnt -c 'passwd redstar'


echo "install script complete. Reboot to continue to NixOS!"

