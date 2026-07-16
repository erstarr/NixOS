{lib, ...}:

{

  services.openssh = {

  setting = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };
    # no server shall run on baremetal
    openFirewall = false;

  };

  # Prevent sshd from autostarting
  systemd.services.sshd.wantedBy = lib.mkForce [ ];



}