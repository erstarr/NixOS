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

FLAKE_DIR="$(dirname "$SCRIPT_DIR")"  # step up from scripts/ to repo root -- where flake.nix is

# DISKO_PATH="$FLAKE_DIR/modules/imported/disko.nix" # disko.nix

HOSTNAME="nixos" # match key in nixosConfigurations


echo "Flake Dir: $FLAKE_DIR"
echo "Host Name:  $HOSTNAME"

# 1. Wipe, partition, format, mount
confirm "STEP 1: Wipe, partition, format and mount disk. THIS IS DESTRUCTIVE. Continue?"

# To avoid surprises, use the disko version from flake.lock to partition disks
echo "extracting disko version from flake.lock..."
DISKO_REV=$(nix eval --impure --raw --expr \
  "(builtins.fromJSON (builtins.readFile \"${FLAKE_DIR}/flake.lock\")).nodes.disko.locked.rev")

# Stright from https://github.com/nix-community/disko/blob/master/docs/quickstart.md - with modifs
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/${DISKO_REV}#disko -- --mode destroy,format,mount --flake "${FLAKE_DIR}#${HOSTNAME}"




# 2 Create hardwareConfigurations file and copy it over
confirm "STEP 2: Generate hardware configuration. Continue?"
# --no-filesystems because disko owns that
# gen the hardware config, write it to current config dir
sudo nixos-generate-config --root /mnt --no-filesystems --show-hardware-config > "$FLAKE_DIR/hardware-configuration.nix"
git add -A "$FLAKE_DIR/hardware-configuration.nix"


# 3. Nix Install
confirm "STEP 3: Run nixos-install. Continue?"
# --no-root-passwd since the root is locked
sudo nixos-install --flake "${FLAKE_DIR}#${HOSTNAME}" --no-root-passwd



echo "Prep for step 4: creating .gitignore for password files..."
sudo mkdir -p /mnt/persist/passwords
echo "*" | sudo tee /mnt/persist/passwords/.gitignore > /dev/null

# 4. User Password setting - Username: redstar
confirm "STEP 4: Setting user password. Continue?"
sudo mkpasswd -m yescrypt | sudo tee /mnt/persist/passwords/redstar > /dev/null
# Tighten Permissions
sudo chmod 700 /mnt/persist/passwords
sudo chmod 600 /mnt/persist/passwords/redstar


confirm "STEP 5: Copy NixOS config to persistent home. Continue?"
sudo mkdir -p /mnt/persist/home/redstar/NixOS_Config
sudo cp -r "$FLAKE_DIR/." /mnt/persist/home/redstar/NixOS_Config/


confirm "STEP 6: Fix ownership. Continue?"
# In home so user must own it -- single user system so just redstar
sudo nixos-enter --root /mnt -c 'chown -R redstar:redstar /persist/home/redstar'
sudo nixos-enter --root /mnt -c 'chown -R redstar:redstar /persist/home/redstar/NixOS_Config'

# Needed as systemd will first craete it in ephemeral filesystem otherwise. --> there's an exception for this already and it's auto handled
# confirm "STEP 7: Persisting machine-id early. Continue?"
# # Imperm during nixos-install must have creted this by now
# sudo nixos-enter --root /mnt -c 'sudo cp -p /etc/machine-id /persist/etc/machine-id'


confirm "STEP 7 Moving the install log into /var/log (persistent target)..."
sudo mv /tmp/install.log /mnt/var/log

echo "install script complete. Reboot to continue to NixOS!"

