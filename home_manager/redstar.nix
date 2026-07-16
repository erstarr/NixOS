{ ... }:

{

  imports = [ ./redstar_homeImpermanence.nix ];

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
    };
  };

  programs = {

    # manages bash now: .bashrc, .bash_logout, etc...
    bash.enable = true;

  };

  # Don't touch this - Stays at the version originally installed
  home.stateVersion = "26.05"; # see Bug 2
}
