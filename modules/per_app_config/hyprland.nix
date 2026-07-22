# Can use the nix pkgs package or can use a flake. Flip the switch to switch between them


{pkgs, config, lib,
# Hyprland flake
hyprland,
...}:

let
  useFlake = config.custom.hyprland.useFlake;
  sys      = pkgs.stdenv.hostPlatform.system;
in
{

  # Configuration done in the lua config file, not here

  # Hyprland
  programs.hyprland.enable = true;
  # Hypridle
  services.hypridle.enable = true;
  # Hyprlock
  programs.hyprlock.enable = true;

  programs.hyprland = {

    package = if useFlake
      then hyprland.packages.${sys}.hyprland
      else pkgs.hyprland;

    # keeps the portal in sync with whichever source chosen
    portalPackage = if useFlake
      then hyprland.packages.${sys}.xdg-desktop-portal-hyprland
      else pkgs.xdg-desktop-portal-hyprland;
  };


  # Pin mesa to Hyprland's locked nixpkgs IF using the flake.
  # lib.mkIf is important --> lazy evaluation means the right-hand side is never forced when useFlake = false, so there's no spurious evaluation of Hyprland's pkgsi686Linux tree.
  hardware.graphics.package   = lib.mkIf useFlake
    (hyprland.inputs.nixpkgs.legacyPackages.${sys}.mesa);
  hardware.graphics.package32 = lib.mkIf useFlake
    (hyprland.inputs.nixpkgs.legacyPackages.${sys}.pkgsi686Linux.mesa);



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

  # Cache so you don't rebuild all hyprland deps every time you update (inc mesa. etc...) -- only relevant if using flakes
  nix.settings = lib.mkIf useFlake {
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