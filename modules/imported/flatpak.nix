{ nix-flatpak, ... }:

{

  imports = [ nix-flatpak.nixosModules.nix-flatpak ];



  ######################
  # IMPORTANT: It does add the --unused flag during an uninstall, but doesn't add --delete-data!
  ####> Practical: Run the flatpak uninstall command YOURSELF before removing the package from the config!
  ####> Theoretical: You need to either run the full uninstall command yourself before removing the package from the config, or delete the data from ~/.var/app/ yourself!
  ######################


  services.flatpak = {

    enable = true;

    # have nix-flatpak manage the lifecycle of all flatpaks packages and repositories (i.e. if you installed the flatpak using flatpak's own commands, setting this to true will uninstall it on next nixos-rebuild switch)
    uninstallUnmanaged = true;

    uninstallUnused = true;

    # Expicitly disable auto update
    update = {
      onActivation = false; # so that repeated invocations of nixos-rebuild switch are idempotent - WARNING: you have to update flatpaks yourself!

      auto = {
        enable = false;
        onCalendar = "weekly"; # Default value
      };
    };

    # Overrides are linked to place with home manager so i can edit perms with flatseal

    # remotes = []; # By default  flathub is already added
    packages = [

      {
        appId = "com.github.tchx84.Flatseal";
        origin = "flathub";
      }

      {
        appId = "org.mozilla.firefox";
        origin = "flathub";
      }

      {
        appId = "com.obsproject.Studio";
        origin = "flathub";
      }

      {
        appId = "com.visualstudio.code";
        origin = "flathub";
      }

      {
        appId = "md.obsidian.Obsidian";
        origin = "flathub";
      }

      {
        appId = "net.ankiweb.Anki";
        origin = "flathub";
      }

      {
        appId = "org.kde.dolphin";
        origin = "flathub";
      }

      {
        appId = "org.kde.kate";
        origin = "flathub";
      }

    ];
  };

}
