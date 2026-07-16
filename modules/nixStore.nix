{



  # Auto clean up past system builds
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Hard-links identical files in the store - saves space
  nix.optimise.automatic = true;

}