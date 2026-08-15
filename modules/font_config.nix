{pkgs, ...}:

{


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