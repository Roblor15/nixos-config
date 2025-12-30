{
  config,
  pkgs,
  lib,
  inputs,
  variants,
  ...
}:

let
  domain = "lorenzon-nas.duckdns.org";
  domainDn = "dc=lorenzon-nas,dc=duckdns,dc=org";
in
{
  imports = [
    ./services
    ./zfs.nix
    ./users.nix
  ];

  # STABILITÀ: Usa il kernel LTS (Long Term Support) per un server, non il latest.
  # Specialmente vitale se userai ZFS in futuro.
  boot.kernelPackages = pkgs.linuxPackages;

  # --- BOOTLOADER (CRITICO: DEVE ESSERE ABILITATO) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Supporto filesystems (aggiungi zfs o btrfs se li userai)
  boot.supportedFilesystems = [ "ntfs" "zfs" ]; # + "zfs" ?

  # HostID univoco (generalo col comando: head -c4 /dev/urandom | od -A none -t x4)
  networking.hostId = "21309321";

  # --- HARDWARE & SENSORI ---
  hardware.i2c.enable = true;
  hardware.sensor.iio.enable = true;
  # Abilita accelerazione hardware per transcoding (es. Plex/Jellyfin)
  hardware.graphics = {
    enable = true;
    # extraPackages = [ pkgs.intel-media-driver ]; # Se hai CPU Intel aggiungi questo
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
    password = "test"; # Comodo per debug rapido
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

  # --- SERVIZI ---
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no"; # Meglio disabilitare root via SSH per sicurezza
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
  ];

  # Allow unfree (per driver o codec)
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = variants.initialVersion;

  virtualisation.vmVariant = {
    # 1. Risorse Hardware VM
    virtualisation = {
      memorySize = 4096; # 4GB RAM
      diskSize = 10240;
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
      plugins = [ "github.com/caddy-dns/duckdns@v0.5.0" ];
      hash = "sha256-xVjw7QfnjdWIYGTfc4Ca91l8NeeEb/YKE8tMs4ctzTA=";
    };
    virtualHosts."*.${domain}".extraConfig = ''
      # 1. Configurazione TLS centralizzata (il token va nel file secret come detto prima)
      tls {
        dns duckdns {$DUCKDNS_TOKEN}
      }

      # tls internal

      # 2. Gestione default per sottodomini inesistenti (opzionale ma pulito)
      handle {
        abort
      }
    '';
  };
  age.secrets.duckdns_key = {
    file = ../secrets/duckdns_key.age;
    owner = "caddy";
    group = "caddy";
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.duckdns_key.path;

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
    enable = true;
    domain = domain;
  };
  myNas.security.authelia = {
    enable = true;
    domain = domain;
  };
  myNas.services.ente = {
    enable = true;
    domain = domain;
  };
  myNas.services.lldap = {
    enable = true;
    domain = domain;
    baseDn = domainDn;
  };
  myNas.services.rustfs = {
    enable = true;
    domain = domain;
  };
  myNas.services.seafile = {
    enable = true;
    domain = domain;
  };
  myNas.users = {
    enable = true;
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
}
