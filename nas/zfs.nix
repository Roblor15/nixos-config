{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "hddpool" ];

  # --- 1. TUNING PERFORMANCE (16GB RAM) ---
  boot.kernelParams = [ "zfs.zfs_arc_max=8589934592" ];

  services.sanoid = {
    enable = true;
    interval = "minutely"; # Esegue lo script ogni minuto per precisione, ma crea snap secondo policy

    # Definizione delle policy (quanti backup tenere)
    templates = {
      # Policy per SSD (rpool): Mantieni frequenti snapshot recenti, ma pulisci in fretta
      ssd_backup = {
        autoprune = true;
        autosnap = true;
        hourly = 24;
        daily = 7;
        monthly = 0; # Spostiamo i mensili sull'HDD via Syncoid
        yearly = 0;
      };

      # Policy per HDD (hddpool): Storage a lungo termine
      hdd_backup = {
        autoprune = true;
        autosnap = true;
        hourly = 24;
        daily = 30;
        monthly = 12;
        yearly = 2;
      };
    };

    # Applicazione delle policy ai dataset
    datasets = {
      # RPOOL (SSD): Snapshot dei dati utente e stato sistema
      "rpool/safe/home" = {
        useTemplate = [ "ssd_backup" ];
      };
      "rpool/safe/persist" = {
        useTemplate = [ "ssd_backup" ];
      };
      "rpool/safe/opencloud" = {
        useTemplate = [ "ssd_backup" ];
      };

      # HDDPOOL (HDD): Snapshot dei dati bulk
      "hddpool/immich" = {
        useTemplate = [ "hdd_backup" ];
      };
      "hddpool/oc-users" = {
        useTemplate = [ "hdd_backup" ];
      };
      "hddpool/rustfs" = {
        useTemplate = [ "hdd_backup" ];
      };
    };
  };

  services.syncoid = {
    enable = true;
    # Esegue la sincronizzazione ogni 15 minuti.
    interval = "hourly";

    # Comandi di backup (Local Backup)
    commands = {
      "backup-home" = {
        source = "rpool/safe/home";
        target = "hddpool/backups/home";
        # recursive = true; # Attiva se hai dataset figli
      };
      "backup-persist" = {
        source = "rpool/safe/persist";
        target = "hddpool/backups/persist";
      };
      "backup-opencloud" = {
        source = "rpool/safe/opencloud";
        target = "hddpool/backups/opencloud";
      };
    };
  };

  services.zfs.autoScrub = {
    enable = true;
    interval = "*-*-01,15 02:00";
    pools = [
      "rpool"
      "hddpool"
    ];
  };

  services.zfs.zed = {
    enableMail = true;
    settings = {
      # Who gets the alerts?
      ZED_EMAIL_ADDR = [ "roberto.lorenzon.2001@gmail.com" ];
      # Use msmtp to send the mail
      ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
      # Send an email immediately if a drive degrades or faults
      ZED_NOTIFY_VERBOSE = true;
      # Send an email when a scrub finishes (good for testing it works)
      ZED_NOTIFY_DATA = true;
    };
  };

  services.smartd = {
    enable = true;
    autodetect = true;
    defaults.autodetected = "-a -o on -S on -n standby,q -s (S/../.././03|L/../10/./04)";
    notifications.mail.enable = true;
    notifications.mail.recipient = "roberto.lorenzon.2001@gmail.com";
    notifications.mail.sender = "roberto.lorenzon.2001@gmail.com";
  };

  # Crea "foto" del filesystem. Ti salva se cancelli file per sbaglio.
  # services.zfs.autoSnapshot = {
  #   enable = true;
  #   frequent = 4; # Ogni 15 min (ultimi 4)
  #   hourly = 24; # Ultime 24 ore
  #   daily = 7; # Ultimi 7 giorni
  #   weekly = 4; # Ultime 4 settimane
  #   monthly = 6; # Ultimi 6 mesi
  # };

  age.secrets.brevo_password = {
    file = ../secrets/brevo_password.age;
    owner = "root";
    group = "root";
  };

  # --- CONFIGURAZIONE EMAIL (Richiesta per ZED e Smartd) ---
  # Per ricevere le mail sopra, devi configurare un sender.
  # Esempio minimale con msmtp (richiede pacchetto 'msmtp').
  programs.msmtp = {
    enable = true;
    accounts = {
      default = {
        auth = true;
        tls = true;
        host = "smtp-relay.brevo.com";
        port = 587;
        user = "9ecdc8001@smtp-brevo.com";
        passwordeval = "cat ${config.age.secrets.brevo_password.path}";
        from = "roberto.lorenzon.2001@gmail.com";
      };
    };
  };
}
