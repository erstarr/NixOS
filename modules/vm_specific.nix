{
  lib,
  pkgs,
  ...
}:

{
  # THIS IS VM SPECIFIC
  services.openssh = {

    enable = true;
    settings.PasswordAuthentication = true;

  };
  # THIS IS VM SPECIFIC - Allow SSHD through --- Note: multiple mkForces concatonate instead of competing
  networking.firewall.allowedTCPPorts = lib.mkForce [ 22 ];


  # Persist .vscode-server
  home-manager.users.redstar = { osConfig, ... }: {
    home.persistence."/persist" =
      # if not persisting entire home dir
      lib.mkIf (!osConfig.custom.impermanence.entireHomeDirImpermanence) {

        directories = [
          ".vscode-server"
        ];
        files = [
          
        ];
      };
  };

  environment.systemPackages = with pkgs; [
    nixd # Language Server
    nixfmt # Formatter
  ];

  # File Share from Host (virtiofs) - comment out when not in use
  # boot.kernelModules = [ "virtiofs" ];

  # fileSystems."/mnt/shared" = {
  #   device = "fileShare";
  #   fsType = "virtiofs";
  #   options = [ "_netdev" ];
  # };

}
