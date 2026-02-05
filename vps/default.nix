{
  config,
  pkgs,
  lib,
  inputs,
  variants,
  NASOptions,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.hostName = variants.hostName;
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  # Permetti SSH e mDNS nel firewall
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [
    51821
  ];

  # Port Forwarding (Tutto il traffico web va al NAS)
  networking.nat = {
    enable = true;
    externalInterface = "ens6"; # Conferma con 'ip a' sul VPS (dal tcpdump sembra ens6)
    internalInterfaces = [ "wg1" ];
    forwardPorts = [
      {
        sourcePort = 80;
        destination = "10.100.0.2:80";
        proto = "tcp";
      }
      {
        sourcePort = 443;
        destination = "10.100.0.2:443";
        proto = "tcp";
      }
    ];
  };

  networking.firewall.extraCommands = ''
    iptables -t nat -A POSTROUTING -o wg1 -j MASQUERADE
  '';

  # --- LOCALIZZAZIONE ---
  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  users.users.root = {
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZQFd6dJ1F8f8lHnJ0OEGnnR7LODjshdu3wz/S/okSW roblor@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/sr4SCrEhqqGnBOGyhD+NJqW8kKyri1/EOVGoSivTV roblor@roblor-desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHs8fZIPGNqw3rtvzw80UkN/uan20sNzXh1AHuy/UcAm General purpose key"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGIlkz6tQ5lwvgcYogFpHQm84fbO1btLaFp5EBZbn0slL+bC1zEvfVZEV9JePUI/254FnaUl6qUULI0Ad/fNFqU="
    ];
  };

  # --- SERVIZI ---
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password"; # Meglio disabilitare root via SSH per sicurezza
    };
  };

  # Headless: Niente X11
  services.xserver.enable = false;

  # Shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      nix-your-shell fish | source
    '';
  };
  programs.git.enable = true; # Sempre utile avere git

  # Nix Settings ottimizzati per Server (senza cache grafiche inutili)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings = {
    trusted-users = [
      "root"
      "roblor"
    ];
    auto-optimise-store = true; # Risparmia spazio su disco automaticamente
  };

  # --- PACCHETTI DI SISTEMA ---
  environment.systemPackages = with pkgs; [
    # Tools CLI essenziali per NAS
    helix
    htop
    nix-your-shell
    tcpdump
  ];

  # Allow unfree (per driver o codec)
  system.stateVersion = variants.initialVersion;

  # age.secrets.netbird_key = {
  #   file = ../secrets/netbird_key.age;
  #   mode = "400"; # Solo root può leggerla
  # };

  # services.netbird.enable = true;

  # 3. Servizio Systemd per fare "netbird up" automatico
  # systemd.services.netbird-auto-login = {
  #   description = "Netbird Auto Login via Setup Key";
  #   after = [
  #     "netbird.service"
  #     "network-online.target"
  #   ];
  #   wants = [ "network-online.target" ];
  #   wantedBy = [ "multi-user.target" ];

  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     # Script che esegue il login
  #     ExecStart = pkgs.writeShellScript "netbird-up-script" ''
  #       # Attendi qualche secondo che il demone sia responsive
  #       sleep 5

  #       # Leggi la chiave dal file agenix
  #       NB_KEY=$(cat ${config.age.secrets.netbird_key.path})

  #       # Esegui il comando di join
  #       # --setup-key: usa la chiave
  #       # --management-url: utile se self-hosti netbird (opzionale se usi SaaS)
  #       ${pkgs.netbird}/bin/netbird up --setup-key "$NB_KEY"
  #     '';
  #   };
  # };

  services.iperf3 = {
    enable = true;
    port = 5201;
    openFirewall = true;
  };

  age.secrets.wg-private = {
    file = ../secrets/vps-wg-private.age;
    mode = "600";
    owner = "root";
    group = "root";
  };
  age.secrets.wg-preshared = {
    file = ../secrets/wg-preshared.age;
    mode = "600";
    owner = "root";
    group = "root";
  };

  # Configurazione WireGuard
  networking.wg-quick.interfaces = {
    wg1 = {
      address = [ "10.100.0.1/24" ];
      listenPort = 51821;
      privateKeyFile = config.age.secrets.wg-private.path;

      peers = [
        {
          publicKey = "uJv/kHaiEX++HNuG+88lPWcOilr8RYDmegNBZVZI6H0=";
          presharedKeyFile = config.age.secrets.wg-preshared.path;

          # Qui autorizziamo l'IP del NAS
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
    };
  };

  age.secrets.duckdns_key = {
    file = ../secrets/duckdns_key.age;
    owner = "root";
    group = "root";
  };
  age.secrets.dynu_env = {
    file = ../secrets/dynu_env.age;
    owner = "root";
    group = "root";
  };

  systemd.services.dynu-updater = {
    description = "Update Dynu IP with VPS Public IP";
    script = ''
      # Dynu Update URL
      # Assicurati che nel file .age ci siano: DYNU_HOSTNAME e DYNU_PASSWORD
      RESPONSE=$(${pkgs.curl}/bin/curl -s "https://api.dynu.com/nic/update?hostname=$OWN_DYNU_DOMAIN&password=$DYNU_PASSWORD")

      echo "DEBUG: Risposta da Dynu: '$RESPONSE'"

      # Dynu risponde con "good <IP>" se aggiornato o "nochg <IP>" se non cambiato
      if [[ "$RESPONSE" == "good"* ]] || [[ "$RESPONSE" == "nochg"* ]]; then
        echo "Successo: $RESPONSE"
      else
        echo "ERRORE: Aggiornamento fallito! Risposta: $RESPONSE"
        exit 1
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      # CORRETTO: dynu_env (non dyno_env)
      EnvironmentFile = config.age.secrets.dynu_env.path;
    };
  };
  systemd.timers.dynu-updater = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
    };
  };

}
