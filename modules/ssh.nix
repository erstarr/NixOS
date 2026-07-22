{ lib, ... }:

{

  services.openssh = {

    settings = {
      enable = true;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    # no server shall run on baremetal
    openFirewall = false;

  };

  # Prevent sshd from autostarting - I just want the client on baremetal
  systemd.services.sshd.wantedBy = lib.mkForce [ ];

}
