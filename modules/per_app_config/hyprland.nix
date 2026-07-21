{pkgs, ...}:

{

  # Configuration done in the lua config file, not here

  # Hyprland
  programs.hyprland.enable = true;
  # Hypridle
  services.hypridle.enable = true;
  # Hyprlock
  programs.hyprlock.enable = true;




  environment.systemPackages = with pkgs; [

      hyprpicker
      hyprsunset

      hyprpolkitagent


      grimblast
  ];



  # XWayland switch - it's enabled by def but explicitly enable here too
  programs.hyprland.xwayland.enable = true;


  # For file pickermodules
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Cache so you don't rebuild all hyprland deps every time you update (inc mesa. etc...)
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    # Required so non-root users are allowed to use the above substituter/keys.
    # Use @wheel for all sudo users, or list your username explicitly.
    trusted-users = ["root" "@wheel"];
  };



  # Graphical Session for Hyprland (since it's def at system level, it's defined for all users) - Need to do this manually at least for now ---- Started by hyprland
  systemd.user.targets.hyprland-session = {
    unitConfig = {
      Description = "Hyprland session";
      BindsTo = "graphical-session.target";
      Wants = "graphical-session-pre.target";
      After = "graphical-session-pre.target";
      PropagatesStopTo = "graphical-session.target";
    };
  };

}