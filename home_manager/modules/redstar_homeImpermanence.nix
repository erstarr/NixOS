{ osConfig, lib, ... }:
{

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