let
  cloudflareDNS = "1.1.1.1";
  cloudflareBackupDNS = "1.0.0.1";

  # 1 Gigabit port
  upstreamInterface = "enp0s31f6";

  # 2.5 Gigabit port
  lanInterface = "enp2s0";

in 
  {

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };

  networking = {
    hostName = "lenovo-m710q-nixos";
    networkmanager.enable = true;
    nameservers = [ 
      "${cloudflareDNS}"
      "${cloudflareBackupDNS}"
    ];
    firewall.enable = false;

    interfaces = {
      ${upstreamInterface} = {
        useDHCP = true;
      };
      ${lanInterface} = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "10.0.0.1";
          prefixLength = 24;
        }];
      };
    };
    # stolen from https://www.jjpdev.com/posts/home-router-nixos/
    nftables = {
      enable = true;
      ruleset = ''
      table ip filter {
        chain input {
            type filter hook input priority 0; policy drop;

            iifname { "${lanInterface}" } accept comment "Allow LAN to access router"
            iifname "${upstreamInterface}" ct state { established, related } accept comment "Allow established traffic"
            iifname "${upstreamInterface}" icmp type { echo-request, destination-unreachable, time-exceeded } counter accept comment "Allow ICMP"
            iifname "${upstreamInterface}" counter drop comment "Drop all other traffic from WAN"
          }
          chain forward {
            type filter hook forward priority 0; policy drop;
            iifname { "${lanInterface}" } oifname { "${upstreamInterface}" } accept comment "Allow trusted LAN to WAN"
            iifname { "${upstreamInterface}" } oifname { "${lanInterface}" } ct  state established, related  accept comment "Allow established connections from wan to lan"
          }
        }

        table ip nat {
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            oifname "${upstreamInterface}" masquerade
          }
        }

        table ip6 filter {
          chain input {
            type filter hook input priority 0; policy drop;
          }
          chain forward {
            type filter hook forward priority 0; policy drop;
          }
        }
      '';
    };
  };



}

