{pkgs, ...}:

{

  # GTK Themes
    dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    # Can set a specific theme here
  };

  # QT Themes

  qt = {
    enable = true;
    platformTheme.name = "gtk"; # follows GTK
    style = {
      name = "adwaita-dark";
      package = with pkgs; [ adwaita-qt adwaita-qt6 ]; # qt5/6
    };
  };

}
