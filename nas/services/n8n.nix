{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.n8n;
in
{
  options.myNas.services.n8n = {
    enable = lib.mkEnableOption "Abilita n8n automation";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio per accedere a n8n";
    };
  };

  config = lib.mkIf cfg.enable {
    services.n8n = {
      enable = true;

      # Apre automaticamente la porta sul firewall di NixOS
      # Indispensabile affinché Gitea e OpenCloud possano inviargli i dati
      openFirewall = true;

      environment = {
        N8N_PORT = "5678";

        # FONDAMENTALE: Imposta il fuso orario corretto.
        GENERIC_TIMEZONE = "Europe/Rome";

        # PRIVACY E RISORSE: Spegniamo la telemetria verso i server di n8n.
        N8N_DIAGNOSTICS_ENABLED = "false";

        # Meno distrazioni: disattiva i fastidiosi popup di aggiornamento nell'interfaccia
        N8N_VERSION_NOTIFICATIONS_ENABLED = "false";

        # IL TRUCCO PER GITEA (Extra bonus)
        WEBHOOK_URL = "https://n8n.${cfg.domain}";

        # INDISPENSABILE SU NIXOS: Evita il timeout dei nodi Code (sia JS che Python)
        N8N_EXECUTION_PROCESS = "main";
      };
    };

    # --- LA SOLUZIONE PER PYTHON ---
    # Questo inietta pacchetti extra direttamente nel PATH del servizio n8n.
    systemd.services.n8n.path = [ 
      pkgs.python3 
      
      # BONUS: Se in futuro i tuoi script Python in n8n avranno bisogno 
      # di librerie esterne (es. requests), commenta la riga sopra e usa questa:
      # (pkgs.python3.withPackages (ps: with ps; [ requests urllib3 ]))
    ];
    # -------------------------------

    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      # Definisci il matcher solo per "auth"
      @n8n host n8n.${cfg.domain}

      # Gestisci la richiesta
      handle @n8n {
        reverse_proxy 127.0.0.1:5678
      }
    '';
  };
}
