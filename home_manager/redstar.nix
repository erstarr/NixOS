

{...}:

{

  imports = [ ./redstar_homeImpermanence.nix ];

  programs = {

    # manages bash now: .bashrc, .bash_logout, etc...
    bash.enable = true;

  };


  # Don't touch this - Stays at the version originally installed
  home.stateVersion = "26.05";  # see Bug 2
}