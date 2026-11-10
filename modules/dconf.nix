{
  # so gtk settings bus to exist
  programs.dconf.enable = true;


  # NIX(?): unable to do this in hyprland config since some programs start before HL can set the env var properly.
  environment.sessionVariables.GDK_WAYLAND_DISABLE = "ext_background_effect_manager_v1";

}