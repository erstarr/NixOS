

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

  # TODO - check if and system-user packages now have a module every now and then - not always desirable to use module mind! ==> implicitly use systemd start and shit
  # System Packages
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

    awww # Wallpaper
    swaync
    waybar
    rofi

    fd
    fzf
    ripgrep
    _7zz # 7zip
    poppler_utils # for pdftoppm

    clipse
  ];

  fonts.packages = with pkgs; [
    noto-fonts

  ];


}