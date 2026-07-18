{pkgs, ...}:

{

  # GTK Themes

  # so gtk settings bus to exist
  programs.dconf.enable = true;

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
      package = pkgs.adwaita-qt6; # also pkgs.adwaita-qt for Qt5 apps
    };
  };

}
