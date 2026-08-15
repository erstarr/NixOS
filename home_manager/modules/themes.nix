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
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    # Can set a specific theme here
  };

  # QT Themes
  qt = {
    enable = true;
    platformTheme.name = "qt6ct"; # sets QT_QPA_PLATFORMTHEME=qt6ct; HM adds qt6ct pkg
    # Style intentionally absent — qt6ct.conf controls style
    # Fusion is Qt-builtin so no package is needed alongside it
  };
 
  # qt6ct config - nix shell qt6ct and pick your settigs. click apply and copy the stuff from its config file to here to change
  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    custom_palette=true
    standard_dialogs=default
    style=Fusion

    [Fonts]
    fixed="Sans,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
    general="Sans,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"

    [Interface]
    activate_item_on_single_click=0
    buttonbox_layout=0
    cursor_flash_time=1200
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
    geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\x4\xf5\0\0\x5{\0\0\0\0\0\0\0\0\0\0\x4\xf8\0\0\x5{\0\0\0\0\x2\0\0\0\n\0\0\0\0\0\0\0\0\0\0\0\x4\xf5\0\0\x5{)

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
  };


}
