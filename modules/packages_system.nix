

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
    swaynotificationcenter # swaync
    waybar
    rofi


    yazi
    # For yazi
    fd
    fzf
    ripgrep
    _7zz # 7zip
    poppler-utils # for pdftoppm

    # Clipboard
    clipse
    wl-clipboard # Need to explicitly pull it in cuz clipse does not
    wtype # For auto-paste script

    satty
  ];

  fonts.packages = with pkgs; [
    noto-fonts

    # Arch Package Name: ttf-jetbrains-mono-nerd
    nerd-fonts.jetbrains-mono
    
    # Arch Package Name: ttf-nerd-fonts-symbols  
    # Arch Package Name: ttf-nerd-fonts-symbols-mono
    nerd-fonts.symbols-only

    # For asian characters
    # Arch Package Name: noto-fonts-cjk
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

  ];


}