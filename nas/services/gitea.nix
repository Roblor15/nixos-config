{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.gitea;
in
{
  options.myNas.services.gitea = {
    enable = lib.mkEnableOption "Abilita Gitea";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio base per accedere a GItea";
      example = "example.com";
    };
  };

  config = lib.mkIf cfg.enable {
    # age.secrets.rustfs_env = {
    #   file = ../../secrets/rustfs_env.age;
    # };

    services.gitea = {
      enable = true;
      appName = "Gitea Lorenzon-Cloud";

      database = {
        type = "postgres";
        user = "gitea";
        name = "gitea";
        createDatabase = true;
        socket = "/run/postgresql"; # Usa il socket Unix (più veloce)
      };

      # --- Configurazione Percorsi (Storage Ibrido) ---
      # stateDir rimane default (/var/lib/gitea) su SSD per sessioni, code, avatar e log.

      # Spostiamo i dati voluminosi su HDD:
      repositoryRoot = "/mnt/hdd/gitea-data/repositories";

      lfs = {
        enable = true; # Abilita Git LFS (fondamentale per file grandi)
        contentDir = "/mnt/hdd/gitea-data/lfs";
      };

      settings = {
        server = {
          # IMPORTANTE: Questo deve essere il tuo dominio pubblico gestito da Caddy
          DOMAIN = "git.${cfg.domain}";
          ROOT_URL = "https://git.${cfg.domain}/";

          # Gitea ascolta su localhost:3000
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 3090;

          # SSH Config
          # Disabilitiamo l'SSH builtin di Gitea per usare quello di sistema o una porta dedicata
          START_SSH_SERVER = true; # Gitea avvia il suo server SSH interno sulla porta 2222
          SSH_PORT = 2222; # Porta esposta per git clone ssh://...
          SSH_LISTEN_PORT = 2222; # Porta su cui Gitea ascolta davvero
        };
      };
    };

    systemd.tmpfiles.settings = {
      "gitea" = {
        "/mnt/hdd/gitea-data/repositories" = {
          d = {
            mode = "0750";
            user = "gitea";
            group = "gitea";
          };
        };
        "/mnt/hdd/gitea-data/lfs" = {
          d = {
            mode = "0750";
            user = "gitea";
            group = "gitea";
          };
        };
      };
    };

  networking.firewall.allowedTCPPorts = [ 2222 ];

    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      @gitea host git.${cfg.domain}

      # Gestisci la richiesta
      handle @gitea {
        reverse_proxy 127.0.0.1:3090
      }
    '';
  };
}
