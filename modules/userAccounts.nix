{
  users.mutableUsers = false;


users = {

  groups = {

    # Create a group same as my username - enforce UPG
    redstar = {};

  };


  users = {

    redstar = {
      isNormalUser = true;
      hashedPasswordFile = "/persist/passwords/redstar";
      group = "redstar";  # enforce UPG
      extraGroups = [
        "wheel" # sudo
        "networkmanager" # For NetworkManager
        "libvirtd"       # For libvirt
      ];

    # User packages - shouldn't need this, don't have/want user packages
    #   packages = with pkgs; [
    #     tree
    #   ];

    };


    # Lock Root
    root = {
      hashedPassword = "!";
    };
  };

};



}
