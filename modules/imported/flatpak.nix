{ nix-flatpak, ... }:

{

  imports = [ nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {

    enable = true;

    uninstallUnmanaged = true; # have nix-flatpak manage the lifecycle of all flatpaks packages and repositories

    # Expicitly disable auto update
    update = {
      onActivation = false; # so that repeated invocations of nixos-rebuild switch are idempotent

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
