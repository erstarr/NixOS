# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  #MARK: VM-ONLY

  # THIS IS VM SPECIFIC
  services.openssh = {

    enable = true;
    settings.PasswordAuthentication = true;

  };
  # THIS IS VM SPECIFIC - Allow SSHD through
  networking.firewall.allowedTCPPorts = [ 22 ];

  # THIS IS VM SPECIFIC - Allow VSCode Remote to run
  programs.nix-ld.enable = true;
  nixpkgs.config.allowUnfree = true;

  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  #MARK: Boot Loader

  boot = {

    kernelPackages = pkgs.linuxPackages_latest;

    loader = {

      grub = {

        # Use the GRUB 2 boot loader.
        enable = true;

        efiSupport = true;
        # efiInstallAsRemovable = true;

        # Define on which hard drive you want to install Grub.
        device = "nodev"; # Using UEFI
      };

      efi = {
        efiSysMountPoint = "/boot/efi"; # So that only efi files are exposed as a fat filesystem
      };

    };
  };

  #MARK: Networking and Firewall

  networking = {

    hostName = "nixos";

    networkmanager = {
      enable = true;

    };

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  #MARK: Time and Locale

  time = {
    timeZone = "Europe/Rome"; # Same timezone as self but different city for privacy
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  console.keyMap = "us";

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  #};

  #MARK: X11

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  #MARK: Sound

  # Enable sound.
  # services.pulseaudio.enable = true; # I'm using pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # just in case
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

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

  # Required for Pipewire
  security.rtkit.enable = true;

  #MARK: Impermemence Filesystem Options

  # Make every persistent and ephemeral filesystem mount at initrd. Root already does, so no need to specify that.
  fileSystems."/persist" = {
    neededForBoot = true;
  };

  fileSystems."/var/log" = {
    neededForBoot = true;
  };

  # TODO this might caue whole home to be persisted(?)
  fileSystems."/home" = {
    neededForBoot = true;
  };

  #MARK SWAP

  # Swap file set in disko flake

  # ZSwap

  boot.zswap = {
    enable = true;
    acceptThresholdPercent = 90;
    shrinkerEnabled = true;
    maxPoolPercent = 25; # kernel default is 20 but extra 5 should work fror better build performance with nix
    # compressor = zstd; # Default - Let nix choose
    # zpool = zsmalloc; # Let nix choose

  };

  #MARK: Accounts

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.redstar = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    # TODO - replace with hashed password asap!
    initialPassword = "changeme"; # passwd it immediately after first login

    # mutableUsers = false; # Impermenence stuff - keep it on for now

    # User packages - shouldn't need this
    #   packages = with pkgs; [
    #     tree
    #   ];
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).

  #MARK: Flakes

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  #MARK: System Packages

  environment.systemPackages = with pkgs; [

    # !!! VM SPECIFIC - COMMENT OUT IN BAREMETAL !!!
    nixd # Language Server
    nixfmt # Formatter

    nano
    git
  ];

  # environment.variables.EDITOR = "nano"; # Might set this up to be flatpakked vscode if that somehow works

  #MARK: Default Stuff

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  #MARK: FRESH INSTALL TODO - Change on fresh install

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
