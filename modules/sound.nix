{
  # Enable sound.
  # services.pulseaudio.enable = true; # I'm using pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # just in case
    pulse.enable = true;
    jack.enable = true;
  };


  # Required for Pipewire
  security.rtkit.enable = true;

  # To achieve parity with arch





}