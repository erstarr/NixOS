{
  hardware = {
    cpu.amd.updateMicrocode = true; # CPU is AMD
    enableRedistributableFirmware = true; # Microcode updates and stuff
  };

  services = {
    xserver.videoDrivers = [ "amdgpu" ]; # GPU is AMD

    fstrim.enable = true; # Trim on SSD
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;   # Steam/Proton/Wine
  };
}