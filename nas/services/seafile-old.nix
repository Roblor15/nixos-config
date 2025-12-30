{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.seafile;
in
{
  options.myNas.services.seafile = {
    enable = lib.mkEnableOption "Abilita Seafile";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio base per accedere a Seafile";
      example = "example.com";
    };
  };

  config = lib.mkIf cfg.enable {

    age.secrets = {
      seafile_oauth = {
        file = ../../secrets/seafile_oauth.age;
        owner = "root";
      };
    };
    virtualisation.oci-containers = {
      containers = {
        seafile-mysql = {
          image = "docker.io/library/mariadb:10.11";
          autoStart = true;
          environment = {
            MYSQL_ROOT_PASSWORD = "rootpass";
            MYSQL_DATABASE = "seafile";
            MYSQL_USER = "seafile";
            MYSQL_PASSWORD = "secretpass";
          };
          volumes = [ "/opt/seafile-mysql/db:/var/lib/mysql" ];
          # We define the hostname explicitly so 'seafile' can find it at "db"
          extraOptions = [ "--hostname=db" ];
        };

        seafile-memcached = {
          image = "docker.io/library/memcached:1.6.40";
          autoStart = true;
          entrypoint = "memcached";
          cmd = [
            "-m"
            "256"
          ];
          # Define hostname explicitly
          extraOptions = [ "--hostname=memcached" ];
        };

        seafile = {
          image = "docker.io/seafileltd/seafile-mc:13.0.12";
          autoStart = true;
          ports = [ "1234:80" ];
          environment = {
            SEAFILE_MYSQL_DB_HOST = "db";
            SEAFILE_MYSQL_DB_PORT = "3306";
            INIT_SEAFILE_MYSQL_ROOT_PASSWORD = "rootpass";
            SEAFILE_MYSQL_DB_USER = "seafile";
            SEAFILE_MYSQL_DB_PASSWORD = "secretpass";
            SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
            SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
            SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seahub_db";

            CACHE_PROVIDER = "redis";
            TIME_ZONE = "Europe/Rome";
            SEAFILE_ADMIN_EMAIL = "me@example.com";
            SEAFILE_ADMIN_PASSWORD = "asecret";
            SEAFILE_SERVER_LETSENCRYPT = "false";
            SEAFILE_SERVER_HOSTNAME = "seafile.${cfg.domain}";
          };
          volumes = [ "/opt/seafile-data:/shared" ];
          dependsOn = [
            "seafile-mysql"
            "seafile-memcached"
          ];
          # No extraOptions needed for network; uses default bridge automatically
        };
      };
    };

    systemd.tmpfiles.settings = {
      "seafile-db" = {
        "/opt/seafile-mysql/db" = {
          d = {
            mode = "0710"; # rwxr-x--- (Secure: only owner/group can read)
            user = "root";
            group = "root";
          };
        };
        "/opt/seafile-data" = {
          d = {
            mode = "0710"; # rwxr-x--- (Secure: only owner/group can read)
            user = "root";
            group = "root";
          };
        };
      };
    };

    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      @seafile host seafile.${cfg.domain}

      # Gestisci la richiesta
      handle @seafile {
        reverse_proxy 127.0.0.1:1234
      }
    '';

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
                CONF_DIR="/opt/seafile-data/seafile/conf"
                CONF_FILE="$CONF_DIR/seahub_settings.py"
                
                # 2. Crea la cartella se non esiste (per le nuove installazioni)
                mkdir -p "$CONF_DIR"

                # 3. Leggi la password dal file secret di Agex (decifrato)
                # Nota: usiamo cat perché lo script gira come root
                SEAFILE_OAUTH=$(cat ${config.age.secrets.seafile_oauth.path})

                # 4. Verifica se LDAP è già configurato per evitare duplicati
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
        EOF
                else
                  echo "Configurazione Authelia già presente. Salto l'iniezione."
                fi
      '';
    };
  };
}
