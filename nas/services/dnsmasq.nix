{ config, pkgs, lib, ... }:

{
  # 1. DISABILITA il gestore DNS di default (il colpevole del conflitto)
  services.resolved.enable = false;

  boot.kernel.sysctl = {
    "net.ipv4.ip_nonlocal_bind" = 1;
  };
  
  # 2. Configura Dnsmasq
  services.dnsmasq = {
    enable = true;
    # Sempre riavviare se crasha
    alwaysKeepRunning = true;
    
    settings = {
      # Ascolta su tutto (per rispondere a Netbird)
      listen-address = "127.0.0.1,100.70.241.219,192.168.188.90";
      # interface = [ "lo" "wt0" "eth0" ];
      # Importante: binda le interfacce per evitare race conditions
      bind-interfaces = true;
      
      # Non guardare /etc/resolv.conf (evita loop infiniti)
      no-resolv = true;
      
      # UPSTREAM DNS (A chi chiede Dnsmasq se non sa la risposta?)
      server = [
        "100.100.100.100"  # 1. Chiedi a Netbird (MagicDNS)
        "1.1.1.1"          # 2. Chiedi a Cloudflare (Internet)
        "8.8.8.8"          # 3. Backup Google
      ];

      address = "/.lorenzon-cloud.ddnsfree.com/192.168.188.90";
    };
  };

  # 3. Dici a NixOS: "Il tuo DNS ora sei tu stesso (localhost)"
  networking.nameservers = [ "127.0.0.1" "1.1.1.1" ];
  
  # Evita che NetworkManager sovrascriva /etc/resolv.conf ignorando le nostre impostazioni
  networking.networkmanager.dns = "none";

  # Apri la porta 53 nel firewall
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
