{
  documentation.man.cache = {
    enable = true;
    generateAtRuntime = true; # systemd service equivalent of man-db.timer
  };

  # Avoid "NixOS Manuals" .desktop file from being auto generated
  documentation.nixos.enable = false;

}
