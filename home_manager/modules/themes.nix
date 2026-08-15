{pkgs, ...}:

{

  # GTK Themes - Don't need to mimick nwg-look's outputs since the configurations is simple
    dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
  
  gtk = {
    enable = true;

    iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
    };

    font = {
        name = "Adwaita Sans";
        size = 11;
    };

    gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-toolbar-style = "GTK_TOOLBAR_ICONS";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
        gtk-button-images = 0;
        gtk-menu-images = 0;
        gtk-enable-event-sounds = 1;
        gtk-enable-input-feedback-sounds = 0;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
    };

    gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
    };

  };

  # QT Themes
  qt = {
    enable = true;
    platformTheme.name = "qt6ct"; # sets QT_QPA_PLATFORMTHEME=qt6ct; HM adds qt6ct pkg
    # Style intentionally absent — qt6ct.conf controls style
    # Fusion is Qt-builtin so no package is needed alongside it
  };
 
  # qt6ct config - nix shell qt6ct and pick your settigs. click apply and copy the stuff from its config file to here to change
  xdg.configFile."qt6ct/colors/darker.conf".source = "${pkgs.qt6ct}/share/qt6ct/colors/darker.conf";
  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    color_scheme_path=${config.xdg.configHome}/qt6ct/colors/darker.conf
    custom_palette=true
    standard_dialogs=default
    style=Fusion

    [Fonts]
    fixed="Noto Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular"
    general="Noto Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular"

    [Interface]
    activate_item_on_single_click=0
    buttonbox_layout=0
    cursor_flash_time=1000
    dialog_buttons_have_icons=2
    double_click_interval=400
    gui_effects=General, AnimateMenu, AnimateCombo, AnimateTooltip, AnimateToolBox
    keyboard_scheme=2
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    stylesheets=@Invalid()
    toolbutton_style=4
    underline_shortcut=2
    wheel_scroll_lines=3

    [SettingsWindow]
    geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\x4\xf5\0\0\x5{\0\0\0\0\0\0\0\0\0\0\x4\xf5\0\0\x5{\0\0\0\0\x2\0\0\0\n\0\0\0\0\0\0\0\0\0\0\0\x4\xf5\0\0\x5{)

    [Troubleshooting]
    force_raster_widgets=1
    ignored_applications=@Invalid()
  '';

  # Cursor
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
    gtk.enable = true;  # propagates cursor-theme-name and cursor-theme-size to both settings.ini files
  };


}
