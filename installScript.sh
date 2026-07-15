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

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

FLAKE_DIR="$SCRIPT_DIR" # the main flake root

DISKO_PATH="$SCRIPT_DIR/flakes/disko.nix" # disko.nix is inside flakes/

HOSTNAME="nixos" # match key in nixosConfigurations


echo "Flake Dir: $FLAKE_DIR"
echo "Host Name:  $HOSTNAME"

# 1. Wipe, partition, format, mount
confirm "STEP 1: Wipe, partition, format and mount disk. THIS IS DESTRUCTIVE. Continue?"
# Stright from https://github.com/nix-community/disko/blob/master/docs/quickstart.md
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount "$DISKO_PATH"


# 2.5 Create hardwareConfigurations file and copy it over
confirm "STEP 2: Generate hardware configuration. Continue?"

# --no-filesystems because disko owns that
# gen the hardware config, write it to current config dir
sudo nixos-generate-config --root /mnt --no-filesystems --show-hardware-config > "$FLAKE_DIR/hardware-configuration.nix"
git add -A "$FLAKE_DIR/hardware-configuration.nix"

# 3. Nix Install
confirm "STEP 3: Run nixos-install. Continue (It'll hang until you provide a password)?"
# Explicitly use path not git since i don't want my hardware conf file to be tracked
sudo nixos-install --flake "path:${FLAKE_DIR}#${HOSTNAME}"

confirm "STEP 4: Copy NixOS config to persistent home. Continue?"
sudo mkdir -p /mnt/persist/home/redstar/nixos_config
sudo cp -r "$FLAKE_DIR/." /mnt/persist/home/redstar/nixos_config/


# 4. User Password setting - Username: redstar
confirm "STEP 5: Setting user password. Continue?"
sudo nixos-enter --root /mnt -c 'passwd redstar'


confirm "STEP 6: Fix config ownership in persisted vol. Continue?"
sudo nixos-enter --root /mnt -c 'chown -R redstar: /persist/home/redstar/nixos_config'


confirm "STEP 7 Moving the install log into /var/log (persistent target)"...
sudo mv /tmp/install.log /mnt/var/log

echo "install script complete. Reboot to continue to NixOS!"

