
{
  home-manager,
  impermanence,
  ...
}:
{




  #####################################
  #####################################
  # Using Home-Manager to manage home #
  #####################################
  #####################################



  imports = [ home-manager.nixosModules.home-manager ];


    home-manager = {
      useGlobalPkgs = true;     # uses system nixpkgs instead of bulding its own
      useUserPackages = true;   # installs user packages to /etc/profiles
      extraSpecialArgs = { inherit impermanence; };  # now HM modules can receive it
      users.redstar = import ../home_manager/redstar.nix;
    };





}