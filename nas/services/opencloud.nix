{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.opencloud;

  cspConfig = pkgs.writeText "opencloud-csp.yaml" ''
    directives:
      default-src:
        - "'self'"

      object-src:
        - "'self'"
        - 'blob:'
        - 'data:'
      
      script-src:
        - "'self'"
        - "'unsafe-inline'"
        - "'unsafe-eval'"
      
      style-src:
        - "'self'"
        - "'unsafe-inline'"
      
      img-src:
        - "'self'"
        - 'data:'
        - 'blob:'
      
      font-src:
        - "'self'"
        - 'data:'
      
      connect-src:
        - "'self'"
        - 'https://auth.${cfg.domain}'
        - 'https://onlyoffice.${cfg.domain}'
        - 'blob:'
        - 'https://raw.githubusercontent.com/opencloud-eu/awesome-apps/'
        - 'https://update.opencloud.eu'

      frame-src:
        - 'https://onlyoffice.${cfg.domain}'
      
      frame-ancestors:
        - "'self'"
        - "https://onlyoffice.${cfg.domain}"
      
      base-uri:
        - "'self'"
      
      form-action:
        - "'self'"
        - "https://onlyoffice.${cfg.domain}"
  '';
in
{
  options.myNas.services.opencloud = {
    enable = lib.mkEnableOption "Abilita OpenCloud Server";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio per accedere a OpenCloud";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.opencloud_env = {
      file = ../../secrets/opencloud_env.age;
    };

    # systemd.services.opencloud.serviceConfig.EnvironmentFile = config.age.secrets.opencloud_env.path;
    # 2. Configurazione Servizio OpenCloud
    services.opencloud = {
      enable = true;
      address = "127.0.0.1";
      port = 9200; # Assicurati che coincida con la porta del servizio
      url = "https://opencloud.${cfg.domain}";
      # url = "http://localhost:9200";

      # Parametri specifici richiesti
      user = "opencloud";
      group = "opencloud";
      stateDir = "/mnt/hdd/opencloud";
      # environmentFile = config.age.secrets.opencloud_secrets.path;

      environment = {
        # Basic OIDC Configuration
        "OC_INSECURE" = "true";
        "PROXY_TLS" = "false";
        "OC_OIDC_ISSUER" = "https://auth.${cfg.domain}";
        "OC_EXCLUDE_RUN_SERVICES" = "idp";
        # "OC_JWT_SECRET" = "ciaociao";
        "PROXY_OIDC_REWRITE_WELLKNOWN" = "true";

        # User Mapping Configuration
        "PROXY_USER_OIDC_CLAIM" = "preferred_username";
        "PROXY_USER_CS3_CLAIM" = "username";

        # Account Provisioning
        "PROXY_AUTOPROVISION_ACCOUNTS" = "true";
        # Set to "none" if you enable autoprovision
        # "GRAPH_USERNAME_MATCH" = "none";

        # Web Client Configuration
        "WEB_OIDC_AUTHORITY" = "https://auth.${cfg.domain}";
        "WEB_OIDC_CLIENT_ID" = "opencloud_web";
        "WEB_OIDC_SCOPE" = "openid profile email groups offline_access";

        # Content Security Policy - Reference to YAML file
        "PROXY_CSP_CONFIG_FILE_LOCATION" = "${cspConfig}";

        # Proxy OIDC Configuration
        "PROXY_OIDC_ISSUER" = "https://auth.${cfg.domain}";
        "PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD" = "jwt";
        "PROXY_OIDC_SKIP_USER_INFO" = "false";

        # Autoprovision Claims
        "PROXY_AUTOPROVISION_CLAIM_USERNAME" = "preferred_username";
        "PROXY_AUTOPROVISION_CLAIM_EMAIL" = "email";
        "PROXY_AUTOPROVISION_CLAIM_DISPLAYNAME" = "name";
        "PROXY_AUTOPROVISION_CLAIM_GROUPS" = "groups";

        # Role Assignment Configuration
        # "PROXY_ROLE_ASSIGNMENT_DRIVER" = "oidc";
        "PROXY_ROLE_ASSIGNMENT_OIDC_CLAIM" = "preferred_username";
        "GRAPH_ASSIGN_DEFAULT_USER_ROLE" = "true";
        "OPEN_CLOUD_LOG_LEVEL" = "info";

        # ONLYOFFICE Integration
        "OC_ADD_RUN_SERVICES" = "collaboration";
        "COLLABORATION_APP_NAME" = "OnlyOffice";
        "COLLABORATION_APP_PRODUCT" = "OnlyOffice";
        "COLLABORATION_APP_ADDR" = "https://onlyoffice.${cfg.domain}";

        # WOPI Configuration
        "COLLABORATION_WOPI_SRC" = "https://wopi.${cfg.domain}";

        # Ensure the JWT secret matches ONLYOFFICE's secret if you configured one
        "COLLABORATION_JWT_SECRET" = "ciaociao";
        "COLLABORATION_APP_INSECURE" = "false"; # Add this line
        "COLLABORATION_APP_PROOF_DISABLE" = "true";

        # SMTP configuration
        "NOTIFICATIONS_SMTP_HOST" = "smtp-relay.brevo.com";
        "NOTIFICATIONS_SMTP_PORT" = "587";
        "NOTIFICATIONS_SMTP_SENDER" = "OpenCloud - Lorenzon NAS <roberto.lorenzon.2001@gmail.com>";
        "NOTIFICATIONS_SMTP_USERNAME" = "9ecdc8001@smtp-brevo.com";

        "NOTIFICATIONS_SMTP_TRANSPORT_ENCRYPTION" = "starttls";
        "NOTIFICATIONS_SMTP_INSECURE" = "false";
        "NOTIFICATIONS_SMTP_AUTHENTICATION" = "login";

        "START_ADDITIONAL_SERVICES" = "notifications";
      };

      settings = {
        # http = {
        #   services = {
        #     collaboration = {
        #       bind_addr = "127.0.0.1:9200";
        #     };
        #   };
        # };
        collaboration = {
          # app = {
          # name = "OnlyOffice";
          # addr = "https://onlyoffice.${cfg.domain}";
          # insecure = false;
          # };
          # wopi = {
          #   wopi_src = "https://opencloud.${cfg.domain}";
          # };
        };
        nats = { };
        notifications = { };
        proxy = {
          role_assignment = {
            driver = "oidc";
            oidc_role_mapper = {
              role_claim = "preferred_username";
              role_mapping = [
                {
                  role_name = "admin";
                  claim_value = "admin";
                }
                {
                  role_name = "user";
                  claim_value = "damlor";
                }
                {
                  role_name = "user";
                  claim_value = "princi";
                }
                {
                  role_name = "user";
                  claim_value = "ivano";
                }
                {
                  role_name = "user";
                  claim_value = "rosella";
                }
              ];
            };
          };
        };
      };
    };
    # 3. Configurazione Caddy (Reverse Proxy)
    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      # Matcher per il sottodominio opencloud
      @opencloud host opencloud.${cfg.domain}
      @wopi host wopi.${cfg.domain}

      # 2. Gestione generica traffico OpenCloud (deve stare DOPO quella specifica)
      handle @opencloud {
        reverse_proxy 127.0.0.1:9200
      }
      handle @wopi {
        reverse_proxy 127.0.0.1:9300
      }
    '';
  };
}
