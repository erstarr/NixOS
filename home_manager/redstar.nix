{ ... }:

{

  imports = [
    ./modules/redstar_homeImpermanence.nix
    ./modules/themes.nix

    ./per_app_config/bash.nix
    ./per_app_config/yazi_hm.nix
    ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.


  home = {
    username = "redstar";
    homeDirectory = "/home/redstar";
  };

  # TODO: is it an enable home manager at all switch or?
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true; # In case applications need xdg dirs set as env vars
    };
  };


  # Don't touch this - Stays at the version originally installed
  home.stateVersion = "26.05"; # see Bug 2
}
