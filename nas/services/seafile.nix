{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.seafile;

  # Percorso dove genereremo il file .env per i container che non supportano nativamente i secret file
  seafileEnvFile = "/run/seafile/secrets.env";
in
{
  options.myNas.services.seafile = {
    enable = lib.mkEnableOption "Abilita Seafile Server & SeaDoc";

    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio principale per accedere a Seafile";
      example = "seafile.example.com";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/seafile";
      description = "Directory base per i dati persistenti";
    };

    adminEmail = lib.mkOption {
      type = lib.types.str;
      default = "admin@example.com";
      description = "Email amministratore iniziale";
    };
  };

  config = lib.mkIf cfg.enable {

    # 1. Definizione dei Secret Agenix
    age.secrets = {
      seafile_oauth = {
        file = ../../secrets/seafile_oauth.age;
        owner = "root";
      };
      seafile_db_admin_password = {
        file = ../../secrets/seafile_db_admin_password.age;
        owner = "root";
      };
      seafile_db_user_password = {
        file = ../../secrets/seafile_db_user_password.age;
        owner = "root";
      };
      seafile_admin_password = {
        file = ../../secrets/seafile_admin_password.age;
        owner = "root";
      };
      seafile_redis_password = {
        file = ../../secrets/seafile_redis_password.age;
        owner = "root";
      };
      seadoc_jwt = {
        file = ../../secrets/seadoc_jwt.age;
        owner = "root";
      };
      seafile_email_password = {
        file = ../../secrets/brevo_password.age;
        owner = "root";
      };
    };

    # 2. Servizio di supporto per generare il file .env
    # Questo è necessario perché Seafile/SeaDoc non supportano nativamente variabili "_FILE"
    # e non vogliamo scrivere le password in chiaro nel `environment` di Nix.
    systemd.services.generate-seafile-env = {
      description = "Genera file environment per Seafile dai segreti Agenix";
      requiredBy = [
        "podman-seafile.service"
        "podman-seadoc.service"
      ];
      before = [
        "podman-seafile.service"
        "podman-seadoc.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
      };
      script = ''
        # Imposta permessi restrittivi
        touch ${seafileEnvFile}
        chmod 600 ${seafileEnvFile}

        # Svuota il file per evitare duplicati
        true > ${seafileEnvFile}

        # Scrive le variabili nel formato KEY=VALUE leggendo dai file agenix
        echo "SEAFILE_MYSQL_DB_PASSWORD=$(cat ${config.age.secrets.seafile_db_user_password.path})" >> ${seafileEnvFile}
        echo "INIT_SEAFILE_MYSQL_ROOT_PASSWORD=$(cat ${config.age.secrets.seafile_db_admin_password.path})" >> ${seafileEnvFile}
        echo "INIT_SEAFILE_ADMIN_PASSWORD=$(cat ${config.age.secrets.seafile_admin_password.path})" >> ${seafileEnvFile}
        echo "JWT_PRIVATE_KEY=$(cat ${config.age.secrets.seadoc_jwt.path})" >> ${seafileEnvFile}
        echo "REDIS_PASSWORD=$(cat ${config.age.secrets.seafile_redis_password.path})" >> ${seafileEnvFile}

        # Variabili DB per SeaDoc (riutilizza le stesse password)
        echo "DB_PASSWORD=$(cat ${config.age.secrets.seafile_db_user_password.path})" >> ${seafileEnvFile}
      '';
    };

    systemd.services.init-seafile-ldap = {
      description = "Inject LDAP settings into Seafile configuration";

      # Esegui questo servizio PRIMA che parta il container Seafile
      before = [ "podman-seafile.service" ];
      requiredBy = [ "podman-seafile.service" ];

      # Assicurati che la rete e i secret siano pronti
      after = [ "network.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = "root"; # Deve essere root per scrivere in /opt
      };

      script = ''
                # 1. Definisci i percorsi
                CONF_DIR="${cfg.dataDir}/data/seafile/conf"
                CONF_FILE="$CONF_DIR/seahub_settings.py"
                
                # 2. Crea la cartella se non esiste (per le nuove installazioni)
                mkdir -p "$CONF_DIR"

                # 3. Leggi la password dal file secret di Agex (decifrato)
                # Nota: usiamo cat perché lo script gira come root
                SEAFILE_OAUTH=$(cat ${config.age.secrets.seafile_oauth.path})
                EMAIL_PASS=$(cat ${config.age.secrets.seafile_email_password.path})

                # 4. Verifica se Authelia è già configurato per evitare duplicati
                if ! grep -q "ENABLE_OAUTH = True" "$CONF_FILE" 2>/dev/null; then
                  echo "Iniettando configurazione LDAP in $CONF_FILE..."

                  cat <<EOF >> "$CONF_FILE"

        # ==========================================
        # CONFIGURAZIONE Authelia (GENERATA DA NIXOS)
        # ==========================================
        ENABLE_OAUTH = True
        OAUTH_ENABLE_INSECURE_TRANSPORT = True
        OAUTH_CLIENT_ID = 'seafile' #Must be the same as in Authelia
        OAUTH_CLIENT_SECRET = '$SEAFILE_OAUTH' #Must be the same as in Authelia
        OAUTH_REDIRECT_URL = 'https://seafile.${cfg.domain}/oauth/callback/'
        OAUTH_PROVIDER_DOMAIN = 'auth.${cfg.domain}'
        OAUTH_AUTHORIZATION_URL = 'https://auth.${cfg.domain}/api/oidc/authorization'
        OAUTH_TOKEN_URL = 'https://auth.${cfg.domain}/api/oidc/token'
        OAUTH_USER_INFO_URL = 'https://auth.${cfg.domain}/api/oidc/userinfo'
        OAUTH_SCOPE = [
          "openid",
          "profile",
          "email",
        ]
        OAUTH_ATTRIBUTE_MAP = {
            "preferred_username": (True, "email"), #Seafile will create a unique identifier of your <LLDAP's User ID >@<the value specified in OAUTH_PROVIDER_DOMAIN>. The identifier is not visible to the user and not actually used as the email address unlike the value suggests
            "name": (False, "name"),
            "id": (False, "not used"),
            "email": (False, "contact_email"),
        }

        # ==========================================
        # CONFIGURAZIONE EMAIL (GENERATA DA NIXOS)
        # ==========================================
        EMAIL_USE_TLS = True
        EMAIL_HOST = 'smtp-relay.brevo.com'
        EMAIL_HOST_USER = '9ecdc8001@smtp-brevo.com'
        EMAIL_HOST_PASSWORD = '$EMAIL_PASS'
        EMAIL_PORT = 587
        DEFAULT_FROM_EMAIL = 'roberto.lorenzon.2001@gmail.com'
        SERVER_EMAIL = 'roberto.lorenzon.2001@gmail.com'
        EOF
                else
                  echo "Configurazione Authelia già presente. Salto l'iniezione."
                fi
      '';
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers = {

        # --- MariaDB Service ---
        seafile-db = {
          image = "mariadb:10.11";
          extraOptions = [ "--hostname=db" ];
          environment = {
            # Nota: Usiamo MYSQL_ROOT_PASSWORD_FILE invece della variabile diretta
            MYSQL_ROOT_PASSWORD_FILE = "/run/secrets/rootpass";
            MYSQL_LOG_CONSOLE = "true";
            MARIADB_AUTO_UPGRADE = "1";
          };
          # Montiamo il segreto direttamente nel container
          volumes = [
            "${cfg.dataDir}/db:/var/lib/mysql"
            "${config.age.secrets.seafile_db_admin_password.path}:/run/secrets/rootpass:ro"
          ];
        };

        # --- Redis Service ---
        seafile-redis = {
          image = "redis";
          extraOptions = [ "--hostname=redis" ];
          # Modifichiamo il comando per leggere la password dal file montato
          cmd = [
            "/bin/sh"
            "-c"
            "redis-server --requirepass \"$(cat /run/secrets/redispass)\""
          ];
          volumes = [
            "${config.age.secrets.seafile_redis_password.path}:/run/secrets/redispass:ro"
          ];
          # La variabile environment REDIS_PASSWORD qui non serve, la legge direttamente il comando
        };

        # --- Seafile Core Service ---
        seafile = {
          image = "seafileltd/seafile-mc:13.0-latest";
          extraOptions = [ "--hostname=seafile" ];
          dependsOn = [
            "seafile-db"
            "seafile-redis"
          ];
          ports = [ "127.0.0.1:20080:80" ];
          volumes = [
            "${cfg.dataDir}/data:/shared"
          ];

          # Carica le variabili sensibili dal file generato dinamicamente
          environmentFiles = [ seafileEnvFile ];

          environment = {
            SEAFILE_MYSQL_DB_HOST = "db";
            SEAFILE_MYSQL_DB_PORT = "3306";
            SEAFILE_MYSQL_DB_USER = "seafile";
            # SEAFILE_MYSQL_DB_PASSWORD = fornito da environmentFiles
            # INIT_SEAFILE_MYSQL_ROOT_PASSWORD = fornito da environmentFiles
            SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
            SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
            SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seahub_db";
            TIME_ZONE = "Etc/UTC";
            INIT_SEAFILE_ADMIN_EMAIL = cfg.adminEmail;
            # INIT_SEAFILE_ADMIN_PASSWORD = fornito da environmentFiles
            # SEAFILE_SERVER_HOSTNAME = "seafile.${cfg.domain}";
            # SEAFILE_SERVER_PROTOCOL = "http";
            SITE_ROOT = "/";
            NON_ROOT = "false";
            # JWT_PRIVATE_KEY = fornito da environmentFiles
            SEAFILE_LOG_TO_STDOUT = "true";
            ENABLE_SEADOC = "true";
            SEADOC_SERVER_URL = "https://seafile.${cfg.domain}/sdoc-server";
            CACHE_PROVIDER = "redis";
            REDIS_HOST = "redis";
            REDIS_PORT = "6379";
            # REDIS_PASSWORD = fornito da environmentFiles
          };
        };

        # --- SeaDoc Service ---
        seadoc = {
          image = "seafileltd/sdoc-server:2.0-latest";
          extraOptions = [ "--hostname=seadoc" ];
          dependsOn = [ "seafile-db" ];
          ports = [ "127.0.0.1:20081:80" ];
          volumes = [
            "${cfg.dataDir}/seadoc:/shared"
          ];

          # Carica le variabili sensibili dal file generato dinamicamente
          environmentFiles = [ seafileEnvFile ];

          environment = {
            DB_HOST = "db";
            DB_PORT = "3306";
            DB_USER = "seafile";
            # DB_PASSWORD = fornito da environmentFiles
            DB_NAME = "seahub_db";
            TIME_ZONE = "Europe/Rome";
            # JWT_PRIVATE_KEY = fornito da environmentFiles
            SEAHUB_SERVICE_URL = "http://seafile";
          };
        };
      };
    };

    systemd.tmpfiles.settings = {
      "seafile" = {
        "${cfg.dataDir}" = {
          d = {
            mode = "0755";
            user = "root";
            group = "root";
          };
        };
        "${cfg.dataDir}/db" = {
          d = {
            mode = "0700";
            user = "root";
            group = "root";
          };
        };
        "${cfg.dataDir}/data" = {
          d = {
            mode = "0755";
            user = "root";
            group = "root";
          };
        };
        "${cfg.dataDir}/seadoc" = {
          d = {
            mode = "0755";
            user = "root";
            group = "root";
          };
        };
        "${seafileEnvFile}" = {
          f = {
            mode = "0600";
            user = "root";
            group = "root";
          };
        };
      };
    };

    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      # Definizione del matcher per l'host
      @seafile host seafile.${cfg.domain}

      # Gestisci tutte le richieste per seafile
      handle @seafile {
        # Gestione socket.io (OnlyOffice/Seadoc integration)
        handle_path /socket.io/* {
          rewrite * /socket.io{uri}
          reverse_proxy 127.0.0.1:20081
        }

        # Gestione sdoc-server
        handle_path /sdoc-server/* {
          rewrite * {uri}
          reverse_proxy 127.0.0.1:20081
        }

        # Fallback per tutto il resto di Seafile (la Web UI principale)
        handle {
          reverse_proxy 127.0.0.1:20080
        }
      }
    '';
  };
}
