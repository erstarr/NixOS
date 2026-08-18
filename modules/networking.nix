{lib, ...}:

{

  networking = {

    hostName = "nixos";

    useDHCP = false;
    dhcpcd.enable = false;


    # Desktop - wifi disabled
    wireless = {
      enable = lib.mkForce false; # nixos networkmanager module forces this on
    };

    # NetworkManager config
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";

      unmanaged = [ "interface-name:wlp9s0" ]; # Make network manager stop spamming log by trying to manage the interface
      
      settings = {

        connectivity = {
          enabled = true;
        };


        connection = {
          # IPv6 Privacy
          "ipv6.ip6-privacy" = "2";


          # Prevent Home Manager from injecting my router's DNS addresses ontained via DHCP into systemd-resolved (redundant if dns = "none") -- TODO TEMPORARY: You prob need to also do this per interface as autogen config per
          # interface has them explicitly set to false which takes precedent over the global value
          "ipv4.ignore-auto-dns" = true;
          "ipv6.ignore-auto-dns" = true;
        };
      };
    };

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  };

  # systemd-resolved
  services.resolved = {

    enable = true;

    settings.Resolve = {

      DNS = [
        "1.1.1.1#cloudflare-dns.com"
        "1.0.0.1#cloudflare-dns.com"

        "2606:4700:4700::1111#cloudflare-dns.com"
        "2606:4700:4700::1001#cloudflare-dns.com"
      ];

      FallbackDNS = [
        "76.76.2.0#p0.freedns.controld.com"
        "76.76.10.0#p0.freedns.controld.com"

        "2606:1a40::#p0.freedns.controld.com"
        "2606:1a40:1::#p0.freedns.controld.com"
      ];

      # All
      Domains = [ "~." ];

      DNSOverTLS = "yes";
      DNSSEC = "yes";
      MulticastDNS = "no";
      LLMNR = "no";
      Cache = "no-negative";
    };

  };

}
