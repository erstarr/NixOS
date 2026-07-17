{ osConfig, lib, ... }:
{

  home.persistence."/persist" =
    # if not persisting entire home dir
    lib.mkIf (!osConfig.custom.impermanence.entireHomeDirImpermanence) {
      directories = [
        ".local"
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