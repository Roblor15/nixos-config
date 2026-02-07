{
  config,
  pkgs,
  lib,
  variants,
  NASOptions,
  ...
}:

{
  imports = [
    ./services
    ./zfs.nix
    ./users.nix
    ./hardware-configuration.nix
  ];

  # STABILITÀ: Usa il kernel LTS (Long Term Support) per un server, non il latest.
  # Specialmente vitale se userai ZFS in futuro.
  boot.kernelPackages = pkgs.linuxPackages;

  boot.kernelModules = [
    "coretemp"
    "it87"
  ];

  # 2. Scarica il pacchetto driver "out-of-tree" (FONDAMENTALE su NixOS)
  # Il kernel standard non supporta IT8613E, serve questo pacchetto extra.
  boot.extraModulePackages = [ config.boot.kernelPackages.it87 ];

  # 3. Configura il driver con l'ID corretto (trovato dai tuoi log)
  # ignore_resource_conflict=1 è spesso necessario su ZimaBoard per evitare conflitti ACPI
  boot.extraModprobeConfig = ''
    options it87 force_id=0x8613 ignore_resource_conflict=1
  '';

  # --- BOOTLOADER (CRITICO: DEVE ESSERE ABILITATO) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Supporto filesystems (aggiungi zfs o btrfs se li userai)
  boot.supportedFilesystems = [
    "ntfs"
    "zfs"
  ]; # + "zfs" ?

  # HostID univoco (generalo col comando: head -c4 /dev/urandom | od -A none -t x4)
  networking.hostId = "51c68d72";

  # --- HARDWARE & SENSORI ---
  hardware.i2c.enable = true;
  hardware.sensor.iio.enable = true;
  # Abilita accelerazione hardware per transcoding (es. Plex/Jellyfin)
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.intel-media-driver
      pkgs.mesa
    ]; # Se hai CPU Intel aggiungi questo
  };

  # --- RETE ---
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
  # interfaces."podman0" = {
  #   allowedTCPPorts = [

  #   ];
  # };
  # networking.firewall.trustedInterfaces = [
  #   "podman0"
  # ];

  # Discovery locale (così puoi fare 'ssh roblor@roblor-nas.local')
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

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

  # --- UTENTI ---
  users.users.roblor = {
    isNormalUser = true;
    description = "Roberto";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video" # Per transcoding HW
      "render" # Spesso serve insieme a video per /dev/dri/renderD128
      "plugdev"
      # "docker" # Se usi docker/podman come socket
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZQFd6dJ1F8f8lHnJ0OEGnnR7LODjshdu3wz/S/okSW roblor@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/sr4SCrEhqqGnBOGyhD+NJqW8kKyri1/EOVGoSivTV roblor@roblor-desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHs8fZIPGNqw3rtvzw80UkN/uan20sNzXh1AHuy/UcAm General purpose key"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGIlkz6tQ5lwvgcYogFpHQm84fbO1btLaFp5EBZbn0slL+bC1zEvfVZEV9JePUI/254FnaUl6qUULI0Ad/fNFqU="
    ];
  };

  users.users.root = {
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

  # Garbage Collection
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.gc.dates = "weekly";

  # Nix Settings ottimizzati per Server (senza cache grafiche inutili)
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
    btop
    smartmontools # CONTROLLO SALUTE DISCHI (SMART)
    pciutils # lspci
    usbutils # lsusb
    ripgrep
    fd
    ffmpeg # Transcoding
    nix-your-shell

    # Gestione dischi CLI (sostituiscono gparted)
    parted
    gptfdisk

    # Network tools
    dig
    rsync
    tcpdump
    lm_sensors
    hdparm
  ];

  # Allow unfree (per driver o codec)
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = variants.initialVersion;

  virtualisation.vmVariant = {
    # 1. Risorse Hardware VM
    virtualisation = {
      memorySize = 4096; # 4GB RAM
      diskSize = 20240;
      cores = 4;

      qemu.options = [
        "-drive file=/home/roblor/nixos/disk1.qcow2,format=qcow2,if=virtio,id=drive2"
        "-drive file=/home/roblor/nixos/disk2.qcow2,format=qcow2,if=virtio,id=drive3"
        "-drive file=/home/roblor/nixos/disk3.qcow2,format=qcow2,if=virtio,id=drive4"
        "-drive file=/home/roblor/nixos/disk4.qcow2,format=qcow2,if=virtio,id=drive5"
      ];
      # Opzionale: Se vuoi vedere la grafica QEMU.
      # Metti false se vuoi testare in modalità puramente terminale
      graphics = false;
    };

    boot.zfs.devNodes = "/dev";
    services.smartd.enable = lib.mkForce false;

    # 2. Utente di test (Esiste SOLO nella VM, non sul NAS vero!)
    users.users.root.password = "root"; # Comodo per debug rapido
    users.users.roblor.password = "test"; # Comodo per debug rapido

    networking.hostName = lib.mkForce "roblor-nas";

    # 3. Port Forwarding (FONDAMENTALE PER UN NAS)
    # Ti permette di fare ssh dalla tua macchina host alla VM
    # Esempio: ssh -p 2222 nixosvmtest@localhost
    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
      {
        from = "host";
        host.port = 3000;
        guest.port = 3000;
      }
    ];
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/duckdns@v0.5.0"
        "github.com/caddy-dns/dynu@v1.0.0"
      ];
      hash = "sha256-5sY/xJjesO4dS4Tp9p6rtrxLk3+p3/wEhd5WbfPAvSM=";
    };
    virtualHosts."*.${NASOptions.domain}".extraConfig = ''
      # 1. Configurazione TLS centralizzata (il token va nel file secret come detto prima)
      # tls internal
      # tls {
      #   dns duckdns {$DUCKDNS_TOKEN}
      # }
      tls {
        dns dynu {$DYNU_API_TOKEN} {
          own_domain {$OWN_DYNU_DOMAIN}
        }
        resolvers 1.1.1.1 8.8.8.8
        propagation_delay 120s
      }

      # 2. Gestione default per sottodomini inesistenti (opzionale ma pulito)
      handle {
        abort
      }
    '';
  };
  # age.secrets.duckdns_key = {
  #   file = ../secrets/duckdns_key.age;
  #   owner = "caddy";
  #   group = "caddy";
  # };
  age.secrets.dynu_env = {
    file = ../secrets/dynu_env.age;
    owner = "caddy";
    group = "caddy";
  };
  # systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.duckdns_key.path;
  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.dynu_env.path;

  age.secrets.netbird_key = {
    file = ../secrets/netbird_key.age;
    mode = "400"; # Solo root può leggerla
  };

  services.netbird.enable = true;

  # 3. Servizio Systemd per fare "netbird up" automatico
  systemd.services.netbird-auto-login = {
    description = "Netbird Auto Login via Setup Key";
    after = [
      "netbird.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Script che esegue il login
      ExecStart = pkgs.writeShellScript "netbird-up-script" ''
        # Attendi qualche secondo che il demone sia responsive
        sleep 5

        # Leggi la chiave dal file agenix
        NB_KEY=$(cat ${config.age.secrets.netbird_key.path})

        # Esegui il comando di join
        # --setup-key: usa la chiave
        # --management-url: utile se self-hosti netbird (opzionale se usi SaaS)
        ${pkgs.netbird}/bin/netbird up --setup-key "$NB_KEY"
      '';
    };
  };

  services.iperf3 = {
    enable = true;
    port = 5201;
    openFirewall = true;
  };

  myNas.services.immich = {
    enable = NASOptions.services.immich;
    domain = NASOptions.domain;
  };
  myNas.security.authelia = {
    enable = NASOptions.services.authelia;
    domain = NASOptions.domain;
  };
  myNas.services.ente = {
    enable = NASOptions.services.ente;
    domain = NASOptions.domain;
  };
  myNas.services.lldap = {
    enable = NASOptions.services.lldap;
    domain = NASOptions.domain;
    baseDn = NASOptions.domainDn;
  };
  myNas.services.rustfs = {
    enable = NASOptions.services.rustfs;
    domain = NASOptions.domain;
  };
  myNas.services.seafile = {
    enable = NASOptions.services.seafile;
    domain = NASOptions.domain;
  };
  myNas.services.opencloud = {
    enable = NASOptions.services.opencloud;
    domain = NASOptions.domain;
  };
  myNas.services.onlyoffice = {
    enable = NASOptions.services.onlyoffice;
    domain = NASOptions.domain;
  };
  myNas.users = {
    enable = NASOptions.services.users;
    users = {
      roberto = {
        email = "roberto.lorenzon.2001@gmail.com";
        quota = "1T";
        uid = "roberto";
      };
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Alias docker=podman
    defaultNetwork.settings.dns_enabled = true; # Important for container names
  };
  virtualisation.oci-containers.backend = "podman";

  age.secrets.wg-private = {
    file = ../secrets/nas-wg-private.age;
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

  # 2. Configurazione WireGuard
  networking.wg-quick.interfaces = {
    wg1 = {
      address = [ "10.100.0.2/24" ];

      # Usa una porta diversa da quella standard di Netbird
      listenPort = 51821;

      # Percorso gestito da Agenix
      privateKeyFile = config.age.secrets.wg-private.path;

      peers = [
        {
          # Chiave PUBBLICA del VPS (può stare in chiaro qui)
          publicKey = "rTaqSCr/vI9Xx7lhHmKvJuClZ3ffgxhDstInU2WWM1Y=";

          # Preshared key (gestita da Agenix)
          presharedKeyFile = config.age.secrets.wg-preshared.path;

          # Indirizzi che il NAS può raggiungere attraverso il tunnel.
          # Se vuoi che il NAS risponda solo al VPS, metti l'IP VPN del VPS.
          # Se metti 0.0.0.0/0 tutto il traffico del NAS esce dal VPS (non credo tu voglia questo).
          allowedIPs = [ "10.100.0.1/32" ];

          # Endpoint del VPS
          endpoint = "87.106.46.103:51821";

          # Fondamentale per il NAT di casa
          persistentKeepalive = 25;
        }
      ];
    };
  };

  hardware.fancontrol = {
    enable = true;
    config = ''
      # Impostazioni Generali
      INTERVAL=10

      # Mappatura Percorsi (Fondamentale su NixOS per stabilità ai riavvii)
      # hwmon0 = coretemp (CPU)
      # hwmon1 = it8613 (Chip Ventole)
      DEVPATH=hwmon0=devices/platform/coretemp.0 hwmon1=devices/platform/it87.2608
      DEVNAME=hwmon0=coretemp hwmon1=it8613

      # Associazione Temperatura -> Ventola
      # Usa la temperatura del Core 0 (temp2_input) o Package (temp1_input) per pilotare la ventola (pwm2)
      FCTEMPS=hwmon1/pwm2=hwmon0/temp1_input

      # Associazione Ventola -> Sensore Giri (Opzionale ma utile per vedere se è ferma)
      FCFANS=hwmon1/pwm2=hwmon1/fan2_input

      # --- CURVA VENTOLA ---
      # Sotto i 45°C spegni la ventola
      MINTEMP=hwmon1/pwm2=45
      # A 75°C vai al massimo
      MAXTEMP=hwmon1/pwm2=75

      # Valori di avvio (PWM 0-255)
      # MINSTART: spinta iniziale per farla partire da ferma (es. 100/255)
      MINSTART=hwmon1/pwm2=100
      # MINSTOP: valore sotto il quale si ferma (es. 60/255)
      MINSTOP=hwmon1/pwm2=60

      # FORZA MODALITÀ MANUALE (Importante per il tuo errore)
      # Dice al driver di non lasciare il controllo al BIOS
      PWM_ENABLE=hwmon1/pwm2=1
    '';
  };

  # 2. Servizio Systemd per configurare i dischi all'avvio
  systemd.services.hdd-config = {
    description = "Configurazione HDD: Disabilita Sleep e APM (Always On)";
    # Eseguilo dopo che i filesystem sono montati
    after = [ "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      # Script che esegue il comando su ogni disco
      ExecStart = pkgs.writeShellScript "configure-hdds" ''
        # Sostituisci con il VERO ID del tuo disco
        DISK1="/dev/disk/by-id/ata-ST4000VN006-3CW104_WW66Z14T"
        DISK2="/dev/disk/by-id/ata-ST4000VN006-3CW104_WW66Z16T"
        DISK3="/dev/disk/by-id/ata-ST4000VN006-3CW104_ZW63XZD4"
        DISK4="/dev/disk/by-id/ata-ST4000VN006-3CW104_ZW63ZJ1X"

        # -B 254: APM al massimo (prestazioni), niente risparmio
        # -S 0:   Timer di spindown DISABILITATO (non si spegne mai)
        ${pkgs.hdparm}/bin/hdparm -B 254 -S 0 $DISK1
        ${pkgs.hdparm}/bin/hdparm -B 254 -S 0 $DISK2
        ${pkgs.hdparm}/bin/hdparm -B 254 -S 0 $DISK3
        ${pkgs.hdparm}/bin/hdparm -B 254 -S 0 $DISK4
      '';
    };
  };

  power.ups = {
    enable = true;
    mode = "standalone";

    ups.tecnoware = {
      driver = "blazer_usb"; # o nutdrv_qx come discusso prima
      port = "auto";
      description = "Tecnoware Strip 800";

      # QUESTA è la parte magica:
      directives = [
        # Ignora il segnale "Low Battery" nativo dell'UPS (che spesso arriva troppo tardi)
        "ignorelb"

        # Definisci tu la soglia critica.
        # Esempio: 50% (appena tocca il 50%, NUT avvia lo shutdown)
        "override.battery.charge.low = 30"

        # Opzionale: spegni se rimangono meno di X minuti stimati (es. 10 minuti)
        # "override.battery.runtime.low = 600"
      ];
    };

    # Il resto rimane uguale (upsmon, users, etc...)
    users.upsmon = {
      password = "password-locale-sicura";
      upsmon = "master";
    };

    upsmon.monitor.tecnoware = {
      user = "upsmon";
      type = "master";
      system = "tecnoware@localhost";
    };
  };
}
