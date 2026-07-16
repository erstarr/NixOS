

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

  ];

  fonts.packages = with pkgs; [
    
  ];


}