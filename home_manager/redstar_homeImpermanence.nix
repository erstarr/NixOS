{ impermanence, osConfig, lib, ... }:
{
  imports = [ impermanence.homeManagerModules.impermanence ];

  home.persistence."/persist/home/redstar" =
    # if not persisting entire home dir
    lib.mkIf (!osConfig.custom.impermanence.entireHomeDirImpermanence) {
      allowOther = true;  # required for non-root bind mounts
      directories = [
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Projects"
        "Public"
        "Templates"
        "Videos"
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