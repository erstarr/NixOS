{lib, ...}:

{

  ############################################################################################################
  #################    firewall rules are enabled/disabled elsewhere in the config too        ################ 
  ############################################################################################################


  networking = {

    # use nftables not legacy iptables
    nftables.enable = true;

  firewall = {

    enable = true;

    # Blanket ban any implicit opening of the firewall
    # You have to use lib.mkForce to open them as well
    allowedTCPPorts = lib.mkForce [];
    allowedUDPPorts = lib.mkForce [];
  };



  };




  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];


}