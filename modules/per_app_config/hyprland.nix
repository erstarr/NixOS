{pkgs, ...}:

{

  # Configuration done in the lua config file, not here

  # Hyprland
  programs.hyprland.enable = true;
  # Hypridle
  services.hypridle.enable = true;
  # Hyprlock
  programs.hyprlock.enable = true;

  programs.hyprland.xwayland.enable = true;


  # Cache so you don't rebuild all hyprland deps every time you update (inc mesa. etc...)
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    # Required so non-root users are allowed to use the above substituter/keys.
    # Use @wheel for all sudo users, or list your username explicitly.
    trusted-users = ["root" "@wheel"];
  };

}