{ impermanence, config, lib, ... }:
{
  imports = [ impermanence.homeManagerModules.impermanence ];

  home.persistence."/persist/home/redstar" =
    # if not persisting entire home dir
    lib.mkIf (!config.custom.impermanence.entireHomeDirImpermanence) {
      allowOther = true;  # required for non-root bind mounts (i.e. needed for home imperm. managed by HM)
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