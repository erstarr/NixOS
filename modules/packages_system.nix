

{
  pkgs,
  yazi, # TODO TEMPORARY - yazi: remove line after yazi's nixpkgs updates 
  ...
}:




let


  # TODO TEMPORARY - yazi: remove block after yazi's nixpkgs updates 
  sys = pkgs.stdenv.hostPlatform.system;
  yaziFlakePatched = yazi.packages.${sys}.yazi.override {
    yazi-unwrapped = yazi.packages.${sys}.yazi-unwrapped.overrideAttrs (prev: {
      postPatch = (prev.postPatch or "") + ''
        sed -i 's/:arg("-m")/:arg("-m")\n    :arg("--walker-skip=.git,node_modules,target,dist,.cache")/' \
          yazi-plugin/preset/plugins/fzf.lua
      '';
    });
  };

in
{
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).


  # install packages with unfree LICENCES
  nixpkgs.config.allowUnfree = true;

  # Nix is not FHS-compliant so this is to compensate
  programs.nix-ld.enable = true;

  # Don't want nix to intall 'default' packages
  environment.defaultPackages = [];

  # TODO MAINTENANCE - check if and system-user packages now have a module every now and then - not always desirable to use module mind! ==> implicitly use systemd start and shit
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

    playerctl # Explicitly installed here - was pulled as waybar dep on arch

    awww # Wallpaper
    swaynotificationcenter # swaync
    waybar
    rofi




    yaziFlakePatched  # TODO TEMPORARY - yazi: remove line after yazi's nixpkgs updates 



    # yazi  # TODO TEMPORARY - yazi: uncomment this line after i remove the yazi flake
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


}