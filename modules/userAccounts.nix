{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.redstar = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    # TODO - replace with hashed password asap!
    initialPassword = "changeme"; # passwd it immediately after first login

    # mutableUsers = false; # Impermenence stuff - keep it on for now

    # User packages - shouldn't need this
    #   packages = with pkgs; [
    #     tree
    #   ];
  };
  
}