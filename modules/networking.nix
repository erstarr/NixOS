{lib, pkgs, ...}:

{

  networking = {

    hostName = "nixos";

    # Prevenet dhcpcd from running
    useDHCP = false;
    dhcpcd.enable = false;


    # Desktop - wifi disabled
    wireless = {
      enable = lib.mkForce false; # nixos networkmanager module forces this on -- Disable WIFI
    };

    # NetworkManager config
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none"; # NETWORMANAGER-DNS: because Network Manager keeps pushing router DNS!

      unmanaged = [ "interface-name:wlp9s0" ]; # Make Network Manager stop spamming log by trying to manage the interface - WIFI disabled so no need for it to be managed
      
      settings = {

        connectivity = {
          enabled = true;
        };

        # TODO TEMPORARY - DNS: You prob need to also do this per interface as autogen config per interface has them explicitly set which takes precedent over the global value
        connection = {
          # IPv6 Privacy
          "ipv6.ip6-privacy" = "2"; # TODO MAINTENANCE: This makes it through because it's unset in autogen configs. To check: `nmcli connection show "Wired connection 1" | grep ip6-privacy`
          "addr-gen-mode" = "stable-privacy";

          # NETWORMANAGER-DNS: Prevent Network Manager from injecting my router's DNS addresses ontained via DHCP into systemd-resolved (redundant if dns = "none") - autogen file has = false so this is useless here
          "ipv4.ignore-auto-dns" = true;
          "ipv6.ignore-auto-dns" = true;
        };
      };

      # NETWORMANAGER-DNS: Network Manager still pushes router DNS via dbus even if it's set to dns = "none" here! This removes all per-link DNS configuration that NM pushed via SetLinkDNS D-Bus call for that specific interface
      # IMPORTANT: If network manager is managing or tracking an interface and that interface needs specific DNS servers other than what I set globally, like VPNs, you need to add it as an exception here!
      #            Use `nmcli dev status` to see which are managed and tracked (i.e. not unmanaged)
      dispatcherScripts = [
        {
          source = pkgs.writeShellScript "revert-link-dns" ''
            IFACE="$1"
            ACTION="$2"
            case "$ACTION" in
              up|reapply|dhcp4-change|dhcp6-change)
                [[ "$IFACE" == "virbr"* ]] && exit 0 # Interface Exception: libvirt virt switches (all those mathcing regex)
                ${pkgs.systemd}/bin/resolvectl revert "$IFACE" || true
                ;;
            esac
          '';
          type = "basic";
        }
      ];


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
