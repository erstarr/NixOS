{
  users.mutableUsers = false;

  users.users = {
    redstar = {
      isNormalUser = true;
      hashedPasswordFile = "/persist/passwords/redstar";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];


    # User packages - shouldn't need this
    #   packages = with pkgs; [
    #     tree
    #   ];
  };


    };

    # Lock Root
    root.hashedPassword = "!";
  };
}
