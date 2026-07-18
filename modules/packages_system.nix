

{
  pkgs,
  ...
}:


{
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).


  # install packages with unfree LICENCES
  nixpkgs.config.allowUnfree = true;

  # Nix is not FHS-compliant so this is to compensate
  programs.nix-ld.enable = true;


  environment.systemPackages = with pkgs; [
    git
    nano
    wget

    inetutils

    man-pages

    kitty

    # Hyprland installed - via its own .nix file

    btop

    fastfetch
    
    alsa-utils
    pavucontrol


  ];

  fonts.packages = with pkgs; [
    noto-fonts

  ];


}