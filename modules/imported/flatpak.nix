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

    overrides = {
      writeMode = "replace";
      pruneUnmanagedOverrides = true; # Remove overrides of deleted applications from the actualy overrides directory (not from my dotfiles dir)
      files = [
        ../../dotfiles/flatpak/overrides/com.obsproject.Studio
        ../../dotfiles/flatpak/overrides/com.visualstudio.code
        ../../dotfiles/flatpak/overrides/md.obsidian.Obsidian
        ../../dotfiles/flatpak/overrides/net.ankiweb.Anki
        ../../dotfiles/flatpak/overrides/org.kde.dolphin
        ../../dotfiles/flatpak/overrides/org.kde.kate
        ../../dotfiles/flatpak/overrides/org.mozilla.firefox
      ];

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

  };

}
