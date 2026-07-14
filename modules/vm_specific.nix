

{
  pkgs,
}:


{
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

  environment.systemPackages = with pkgs; [
    nixd # Language Server
    nixfmt # Formatter
  ];
}
