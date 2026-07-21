
{lib, ...}:

{

  networking = {

    hostName = "nixos";

    # Necessary for manual DNS management
    networkmanager.dns = lib.mkForce "none";
    useDHCP = false;
    dhcpcd.enable = false;

    # NetworkManager config
    networkmanager = {
      enable = true;

      settings = {

        connection = {
          # IPv6 Privacy
          "ipv6.ip6-privacy" = "2";
        };

        connectivity = {
          enabled = true;
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
