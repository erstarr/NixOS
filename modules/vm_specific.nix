

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
  # THIS IS VM SPECIFIC - Allow SSHD through
  networking.firewall.allowedTCPPorts = lib.mkForce [ 22 ];


  environment.systemPackages = with pkgs; [
    nixd # Language Server
    nixfmt # Formatter
  ];
}
