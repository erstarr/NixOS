{
  hardware = {
    cpu.amd.updateMicrocode = true; # CPU is AMD
    enableRedistributableFirmware = true; # Microcode updates and stuff
  };

  services = {
    xserver.videoDrivers = [ "amdgpu" ]; # GPU is AMD
  };

  hardware.graphics = {
    enable = true;
    #  enable32Bit = true;   # Steam/Proton/Wine - don't use so disabled for now
  };
}