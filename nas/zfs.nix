{
  config,
  lib,
  pkgs,
  ...
}:

{
  # --- SUPPORTO BASE ZFS ---
  boot.supportedFilesystems = [ "zfs" ];
  # Importa il pool dati automaticamente
  boot.zfs.extraPools = [ "storage" ];

  # --- 1. TUNING PERFORMANCE (16GB RAM) ---
  # Limita la cache ZFS a 10GB. Lascia 6GB per il sistema.
  boot.kernelParams = [ "zfs.zfs_arc_max=10737418240" ];

  # --- 2. PULIZIA E CORRUZIONE DATI (SCRUB) ---
  # Controlla l'integrità dei dati ogni settimana.
  # FONDAMENTALE per RAIDZ1 per prevenire la morte silenziosa dei dati (bitrot).
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
    pools = [ "storage" ];
  };

  # --- 3. MONITORAGGIO EMAIL (ZED) ---
  # Se un disco fallisce, DEVI saperlo subito per sostituirlo.
  # ZED invia una mail in caso di eventi critici.
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

  # --- 4. SALUTE FISICA DISCHI (SMART) ---
  # Monitora la salute meccanica degli HDD (motore, testine, settori riallocati).
  services.smartd = {
    enable = true;
    autodetect = true;
    # Esegue un test breve ogni giorno alle 3 di notte e uno lungo il sabato
    defaults.autodetected = "-a -o on -S on -n standby,q -s (S/../.././03|L/../../6/04)";
    notifications.mail.enable = true;
    notifications.mail.recipient = "roberto.lorenzon.2001@gmail.com";
  };

  # --- 5. SNAPSHOT AUTOMATICI (Protezione Errore Umano) ---
  # Crea "foto" del filesystem. Ti salva se cancelli file per sbaglio.
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 4; # Ogni 15 min (ultimi 4)
    hourly = 24; # Ultime 24 ore
    daily = 7; # Ultimi 7 giorni
    weekly = 4; # Ultime 4 settimane
    monthly = 6; # Ultimi 6 mesi
  };

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
