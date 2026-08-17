{ ... }:

{

  imports = [
    # Modules
    ./modules/redstar_homeImpermanence.nix
    ./modules/themes.nix
    ./modules/mime_types.nix
    ./modules/home_maintenence.nix

    # Per App
    ./per_app/bash.nix
    ./per_app/clipse.nix
    ./per_app/yazi.nix
    ./per_app/misc_conf.nix
    ./per_app/virt_manager.nix

  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  home = {
    username = "redstar";
    homeDirectory = "/home/redstar";
  };

  # Let Home Manager install and manage itself -- It's integrated into the system so this is a no-op even if enabled
  programs.home-manager.enable = false;

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true; # In case applications need xdg dirs set as env vars
    };
  };

  # FRESH INSTALL TODO - Change on fresh install
  # Don't touch this - Stays at the version originally installed
  home.stateVersion = "26.05"; # see Bug 2
}
