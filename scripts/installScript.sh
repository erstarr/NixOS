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
# Because nix-command is still experimental, i need the --extra-experimental-features "nix-command" line
echo "extracting disko version from flake.lock..."
DISKO_REV=$(nix --extra-experimental-features "nix-command" eval --impure --raw --expr \
  "(builtins.fromJSON (builtins.readFile \"${FLAKE_DIR}/flake.lock\")).nodes.disko.locked.rev")

# Stright from https://github.com/nix-community/disko/blob/master/docs/quickstart.md - with modifs
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/${DISKO_REV}#disko -- --mode destroy,format,mount --flake "${FLAKE_DIR}#${HOSTNAME}"




# 2 Create hardwareConfigurations file and copy it over
confirm "STEP 2: Generate hardware configuration. Continue?"

confirm "STEP 2.1: Deleting Preexisting hardware configuration's innards" # to make sure stale info is firmly sweeped away
echo "" > "$FLAKE_DIR/hardware-configuration.nix"

confirm "STEP 2.2: Generate hardware configuration."
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
sudo mkdir -p /mnt/persist/home/redstar/.config/NixOS_Config
sudo cp -r "$FLAKE_DIR/." /mnt/persist/home/redstar/.config/NixOS_Config/


confirm "STEP 6: Fix ownership. Continue?"
# In home so user must own it -- single user system so just redstar
sudo nixos-enter --root /mnt -c 'chown -R redstar:redstar /persist/home/redstar'
sudo nixos-enter --root /mnt -c 'chown -R redstar:redstar /persist/home/redstar/.config/NixOS_Config'

# Needed as systemd will first craete it in ephemeral filesystem otherwise. --> there's an exception for this already and it's auto handled
# confirm "STEP 7: Persisting machine-id early. Continue?"
# # Imperm during nixos-install must have creted this by now
# sudo nixos-enter --root /mnt -c 'sudo cp -a /etc/machine-id /persist/etc/machine-id'

confirm "STEP 7 Mounting USB and moving user dirst into placem then unmounting the USB"


HOME_DST="/mnt/persist/home/redstar"
HOME_DST_WO_MNT=${HOME_DST#/mnt}

USB_MNT="/tmp/usb_data"
echo ""
echo "Current block devices:"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL
echo ""
read -rp "Enter USB data partition (e.g. /dev/sdb1), or 'skip' to skip: " USB_PART

if [[ "$USB_PART" == "skip" ]]; then
    echo "Skipping USB data transfer."
else
    confirm "STEP 7.1 Clean up /persist/redstar/.var/app/* of any residue"
    sudo rm -rf "${HOME_DST}/.var/app/"*


    confirm "STEP 7.2 Mount USB"
    # Mount the USb insto place - lsblk and let the user enter the usb's name. use that in the following transaction
    sudo mkdir -p "$USB_MNT"
    sudo mount "$USB_PART" "$USB_MNT"

    # Don't forget to dfix ownership and any other metadata that might differ between previous machine and this machine

    confirm "STEP 7.3 Copy over flatpak app data to /persist/home/redstar/.var/app and fix ownership"

    if [[ ! -d "${HOME_DST}/.var/app" ]]; then
        echo ".var/app does not exist on target — creating with correct ownership..."
        sudo nixos-enter --root /mnt -c "mkdir -p ${HOME_DST_WO_MNT}/.var/app && chown redstar:redstar ${HOME_DST_WO_MNT}/.var/app"
    fi

    if [[ -d "${USB_MNT}/.var/app" ]]; then
        sudo cp -a "${USB_MNT}/.var/app/." "${HOME_DST}/.var/app/."
        sudo nixos-enter --root /mnt -c "chown -R redstar:redstar ${HOME_DST_WO_MNT}/.var/app"

    else
        echo "WARNING: .var/app not found on USB. Skipping."
    fi


    
    confirm "STEP 7.4 Copy over User Data to /persist/home/redstar/ and fix ownership"
    # Desktop
    # Documents
    # Downloads
    # Music
    # Pictures
    # Projects
    # Public
    # Template
    # Videos
    for dir in Desktop Documents Downloads Music Pictures Projects Public Templates Videos; do
        if [[ -d "${USB_MNT}/${dir}" ]]; then
            echo "Copying ${dir}..."
            sudo cp -a "${USB_MNT}/${dir}/." "${HOME_DST}/${dir}/."
            sudo nixos-enter --root /mnt -c "chown -R redstar:redstar ${HOME_DST_WO_MNT}/${dir}"
        else
            echo "WARNING: ${dir} not found on USB. Skipping."
        fi
    done



    confirm "STEP 7.6 UNmount USB from /mnt"
    sudo umount "$USB_MNT"
    sudo rmdir "$USB_MNT"
fi

# To be done manually
echo "ATTENTION: Now, or on first(or second, since first boot should be rebooted so imperm properly binds stuff) boot, delete the caches of flatpak apps BEFORE starting any of them!"




confirm "STEP 8 Moving the install log into /var/log (persistent target)..."
sudo mv /tmp/install.log /mnt/var/log

echo "install script complete. Reboot to continue to NixOS!"

