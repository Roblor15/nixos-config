{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.windmill;
in
{
  options.myNas.services.windmill = {
    enable = lib.mkEnableOption "Abilita Windmill automation";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio per accedere a Windmill (es. tuodominio.local)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.windmill = {
      enable = true;

      # --- CONFIGURAZIONE SERVER ---
      serverPort = 4050;
      # Porta per il "Language Server Protocol". Serve per farti funzionare
      # l'autocompletamento del codice nell'editor web di Windmill.
      lspPort = 4051; 
      
      # L'URL base con cui accederai all'interfaccia
      baseUrl = "https://windmill.${cfg.domain}";
      
      # Livello di log. "info" va benissimo per l'uso normale, 
      # se hai problemi puoi cambiarlo in "debug".
      logLevel = "info";

      # --- CONFIGURAZIONE DATABASE ---
      database = {
        # FONDAMENTALE: Dice a NixOS di tirare su PostgreSQL automaticamente
        # e di configurarlo per Windmill. Niente Docker, tutto nativo!
        createLocally = true;
        name = "windmill";
        user = "windmill";
        
        # Nota: Non abbiamo bisogno di usare 'database.url' o 'database.urlPath'
        # perché con createLocally = true NixOS userà i socket UNIX in automatico
        # per una connessione iper-veloce e sicura.
      };
    };

    # --- REVERSE PROXY CADDY ---
    # Adattato sulla base di come avevi configurato n8n.
    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      # Definisci il matcher per Windmill
      @windmill host windmill.${cfg.domain}

      # Gestisci la richiesta inviandola alla porta del server
      handle @windmill {
        reverse_proxy 127.0.0.1:4050
      }
    '';
  };
}
