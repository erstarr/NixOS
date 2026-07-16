

{...}:

{

  imports = [ ./redstar_homeImpermanence.nix ];

  home-manager.users.redstar = {

    programs = {

      # manages bash now: .bashrc, .bash_logout, etc...
      bash.enable = true;

    };


  };




}