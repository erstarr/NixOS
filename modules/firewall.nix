{

  ############################################################################################################
  #################    firewall rules are enabled/disabled elsewhere in the config too        ################ 
  ############################################################################################################


  networking = {

    # use nftables not legacy iptables
    nftables.enable = true;

  firewall = {

    enable = true;
  
  };



  };




  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];


}