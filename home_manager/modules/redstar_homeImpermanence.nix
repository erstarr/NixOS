{ osConfig, lib, ... }:
{
  ######################
  # IMPORTANT: ADDING STUFF TO PERSISTANCE PAST FIRST INSTALL REQUIRES THE MANUAL COPYING OF THE FILES PRESENT THERE IF THE CURRENT STATE MUST BE SAVED!
  ####> sudo cp -p to preserve owner,group,perms
  ######################

  home.persistence."/persist" =
    # if not persisting entire home dir
    lib.mkIf (!osConfig.custom.impermanence.entireHomeDirImpermanence) {
      directories = [
        ".local" # covers quite a bit of apps config stuff like pavucontrol, ... TODO - fragment this! TODO make a script that scans the last X home impermbackups and detecs if there's a dir/file that was in one and not the others
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Projects"
        "Public"
        "Templates"
        "Videos"

        # SSH - mainly for known hosts --> for github ssh auth
        ".ssh"

        # My Nix and Dotfiles
        "NixOS_Config"

        # Flatpak files
        ".var/app"
      ];
      files = [
        ".bash_history"
        # ".bash_logout"
        # ".bash_profile"
        # ".bashrc"
        ".lesshst"
      ];
    };
}