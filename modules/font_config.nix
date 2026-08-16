{pkgs, ...}:

{


  fonts = {
    enableDefaultPackages = false;



    fontconfig = {
      defaultFonts = {
        serif      = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
      

    packages = with pkgs; [
    noto-fonts

    # This was implicitly installed on arch but isn't on nix
    # Used in hyprland groupbars
    nerd-fonts.noto
    # Used on themes.nix
    adwaita-fonts


    # SwayNC
    nerd-fonts.iosevka

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
  };
}