{ osConfig, lib, ... }:
{
  ######################
  # IMPORTANT: ADDING STUFF TO PERSISTANCE PAST FIRST INSTALL REQUIRES THE MANUAL COPYING OF THE FILES PRESENT THERE IF THE CURRENT STATE MUST BE SAVED!
  ####> sudo cp -a to preserve owner,group,perms
  ####> then rm -r the file in the non-/persist location
  ####> Then do a rebuild switch to bind/symlink into place
  ######################

  home.persistence."/persist" =
    # if not persisting entire home dir
    lib.mkIf (!osConfig.custom.impermanence.entireHomeDirImpermanence) {
      directories = [
        ".cache" # To avoid the overhead of some long term cached stuff from being recreated every time. The can just be nuked manually

        # .local stuff
        ".local/state/wireplumber" # per stream volume persistance, which sink/speaker muted, etc... across reboots

        # Flatpak app files
        ".var/app"
        # SSH - mainly for known hosts || 700 is recommended perms --> for github ssh auth
        { directory = ".ssh"; mode = "0700"; }

        # Personal Files
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Projects"
        "Public"
        "Templates"
        "Videos"

        # My Nix config and Dotfiles - must use home-relative path!
        ".config/NixOS_Config"

      ];
      files = [
        # IMPORTANT note about file persistance in imperm (creation of dangling symlink if file not already in /persist) - read the system level imperm nix file
        
        ".local/share/hyprland/lastVersion" # Hyprland last version tracking so i don't get welcome notif every time

        ".bash_history"
      ];
    };
}
