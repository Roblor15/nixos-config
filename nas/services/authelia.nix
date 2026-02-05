{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.security.authelia;
in
{
  options.myNas.security.authelia = {
    enable = lib.mkEnableOption "Authelia Authentication Server";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio per accedere a authelia";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Decifrazione Segreti (Permessi corretti per l'utente authelia-main)
    age.secrets = {
      authelia_jwt = {
        file = ../../secrets/authelia_jwt.age;
        owner = "authelia-main";
      };
      authelia_session = {
        file = ../../secrets/authelia_session.age;
        owner = "authelia-main";
      };
      authelia_storage = {
        file = ../../secrets/authelia_storage.age;
        owner = "authelia-main";
      };
      authelia_oidc_hmac = {
        file = ../../secrets/authelia_oidc_hmac.age;
        owner = "authelia-main";
      };
      authelia_oidc_key = {
        file = ../../secrets/authelia_oidc_key.age;
        owner = "authelia-main";
      };
      authelia_ldap_bind_password = {
        file = ../../secrets/lldap_password.age;
        owner = "authelia-main";
      };
    };

    # 2. Configurazione Servizio
    services.authelia.instances.main = {
      enable = true;

      environmentVariables = {
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
          config.age.secrets.authelia_ldap_bind_password.path;
      };

      secrets = {
        jwtSecretFile = config.age.secrets.authelia_jwt.path;
        sessionSecretFile = config.age.secrets.authelia_session.path;
        storageEncryptionKeyFile = config.age.secrets.authelia_storage.path;
        oidcHmacSecretFile = config.age.secrets.authelia_oidc_hmac.path;
        oidcIssuerPrivateKeyFile = config.age.secrets.authelia_oidc_key.path;
      };

      settings = {
        theme = "auto";
        # default_2fa_method = "webauthn";

        server = {
          address = "tcp://127.0.0.1:9091";
          disable_healthcheck = false;
        };

        log = {
          level = "info";
        };

        # Backend Autenticazione
        authentication_backend = {
          ldap = {
            implementation = "lldap";
            address = "ldap://127.0.0.1:3890";
            timeout = "5s";
            start_tls = false; # Siamo in localhost, va bene false

            user = "uid=admin,ou=people,${config.myNas.services.lldap.baseDn}";

            # La password letta dal file segreto
            # password = ''
            #   $(cat "${config.age.secrets.authelia_ldap_bind_password.path}")
            # '';

            # Configurazione della struttura di LLDAP
            base_dn = config.myNas.services.lldap.baseDn;
            additional_users_dn = "ou=people";
            additional_groups_dn = "ou=groups";

            # Filtri per trovare utenti e gruppi
            users_filter = "(&({username_attribute}={input})(objectClass=person))";
            groups_filter = "(member={dn})";

            # Mappatura attributi (LLDAP -> Authelia)
            attributes = {
              display_name = "displayName";
              username = "uid";
              group_name = "cn";
              mail = "mail";
            };
          };
        };

        # Database (SQLite per semplicità, ma supporta Postgres)
        storage = {
          local = {
            path = "/var/lib/authelia-main/db.sqlite3";
          };
        };

        # Notifiche (Setup base su file, cambia con SMTP per produzione)
        notifier = {
          filesystem = {
            filename = "/var/lib/authelia-main/notification.txt";
          };
        };

        webauthn = {
          disable = false;
          enable_passkey_login = true;
          display_name = "Nas Auth"; # Il nome che appare nel popup del browser/telefono
          attestation_conveyance_preference = "indirect";
          selection_criteria = {
            attachment = "";
            discoverability = "preferred";
            user_verification = "preferred"; # 'preferred' o 'required' permette alla Passkey di valere come 2FA
          };
          # timeout = "60s";
        };

        session = {
          cookies = [
            {
              domain = cfg.domain;
              authelia_url = "https://auth.${cfg.domain}";
              default_redirection_url = "https://www.${cfg.domain}"; # O un altro URL di default
            }
          ];
          name = "authelia_session";
          expiration = "24h";
          inactivity = "3h";
          remember_me = "6M";
        };

        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = "auth.${cfg.domain}";
              policy = "bypass";
            }
            {
              domain = "*.${cfg.domain}";
              policy = "one_factor";
            }
          ];
        };

        # --- OIDC per Immich e Seafile ---
        # TODO: add immich-role
        identity_providers = {
          oidc = {
            cors = {
              endpoints = [
                "authorization"
                "token"
                "revocation"
                "introspection"
                "userinfo"
              ];
              allowed_origins = [
                "https://opencloud.${cfg.domain}"
              ];
              allowed_origins_from_client_redirect_uris = true;
            };
            clients = [
              {
                client_id = "immich";
                client_name = "Immich";
                client_secret = "$pbkdf2-sha512$310000$93wW02TqwnBKs8KckaOPqw$LmyBiQFm8v.xpyA/hHASd6eJ3yGnI66bmAsY6I5bnz59s07SryofmM4QC48JcJ7u0.Wil/c1Ma0hfLhoWtmItg";
                public = false;
                authorization_policy = "one_factor"; # ← ADD THIS LINE
                require_pkce = true;
                redirect_uris = [
                  "https://immich.${cfg.domain}/auth/login"
                  "https://immich.${cfg.domain}/user-settings"
                  "http://immich.${cfg.domain}/auth/login"
                  "http://immich.${cfg.domain}/user-settings"
                  "app.immich:///oauth-callback"
                ];
                scopes = [
                  "openid"
                  "profile"
                  "email"
                ];
                response_types = [ "code" ];
                grant_types = [ "authorization_code" ];
                id_token_signed_response_alg = "RS256";
                userinfo_signed_response_alg = "RS256";
                token_endpoint_auth_method = "client_secret_post";
              }
              {
                client_id = "seafile";
                client_name = "Seafile";
                client_secret = "$pbkdf2-sha512$310000$m8kXmSx15wARR29KYOLTlA$j0e342oZaZc11uho4NoiNPzbQCzeZjMUOG0k8DkwjZtJ1N/xUdthiDiBziTFMLQaJk2lSQF0SYjJ7lWA33mfXQ";
                public = false;
                authorization_policy = "one_factor";
                redirect_uris = [ "https://seafile.${cfg.domain}/oauth/callback/" ];
                scopes = [
                  "openid"
                  "profile"
                  "email"
                ];
                userinfo_signed_response_alg = "none";
              }
              {
                client_id = "opencloud_web"; # Doc uses 'web', but 'opencloud' is allowed for this one specific client
                client_name = "OpenCloud Web";
                # client_secret = "$pbkdf2-sha512$310000$YOUR_HASH"; # Configurable for Web, but technically docs say 'Public'
                public = true; # You can keep this false ONLY for the web client if the Proxy handles it
                authorization_policy = "one_factor";
                require_pkce = true;
                access_token_signed_response_alg = "RS256";
                redirect_uris = [
                  "https://opencloud.${cfg.domain}/"
                  "https://opencloud.${cfg.domain}/oidc-callback.html"
                  "https://opencloud.${cfg.domain}/oidc-silent-redirect.html"
                ];
                scopes = [
                  "openid"
                  "profile"
                  "email"
                  "groups"
                  "offline_access"
                ];
                grant_types = [
                  "authorization_code"
                  "refresh_token"
                ];
                userinfo_signed_response_alg = "none";
              }

              # 2. Desktop Client (MUST be exactly 'OpenCloudDesktop')
              {
                client_id = "OpenCloudDesktop"; # [cite: 21]
                client_name = "OpenCloud Desktop";
                public = true; # [cite: 22]
                authorization_policy = "one_factor";
                require_pkce = true;
                access_token_signed_response_alg = "RS256";
                redirect_uris = [
                  "http://127.0.0.1"
                  "http://localhost"
                ]; # [cite: 23]
                scopes = [
                  "openid"
                  "profile"
                  "email"
                  "groups"
                  "offline_access"
                ];
                response_types = [ "code" ];
                grant_types = [
                  "refresh_token"
                  "authorization_code"
                ];
                token_endpoint_auth_method = "none";
                userinfo_signed_response_alg = "none";
              }

              # 3. Android Client (MUST be exactly 'OpenCloudAndroid')
              {
                client_id = "OpenCloudAndroid"; # [cite: 24]
                client_name = "OpenCloud Android";
                public = true; # [cite: 25]
                authorization_policy = "one_factor";
                require_pkce = true;
                access_token_signed_response_alg = "RS256";
                redirect_uris = [ "oc://android.opencloud.eu" ]; # [cite: 26]
                scopes = [
                  "openid"
                  "profile"
                  "email"
                  "groups"
                  "offline_access"
                ];
                response_types = [ "code" ];
                grant_types = [
                  "refresh_token"
                  "authorization_code"
                ];
                token_endpoint_auth_method = "none";
                userinfo_signed_response_alg = "none";
              }

              # 4. iOS Client (MUST be exactly 'OpenCloudIOS')
              {
                client_id = "OpenCloudIOS"; # [cite: 27]
                client_name = "OpenCloud iOS";
                public = true; # [cite: 28]
                authorization_policy = "one_factor";
                require_pkce = true;
                access_token_signed_response_alg = "RS256";
                redirect_uris = [ "oc://ios.opencloud.eu" ]; # [cite: 29]
                scopes = [
                  "openid"
                  "profile"
                  "email"
                  "groups"
                  "offline_access"
                ];
                response_types = [ "code" ];
                grant_types = [
                  "refresh_token"
                  "authorization_code"
                ];
                token_endpoint_auth_method = "none";
                userinfo_signed_response_alg = "none";
              }
            ];
          };
        };
      };
    };

    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      # Definisci il matcher solo per "auth"
      @auth host auth.${cfg.domain}

      # Gestisci la richiesta
      handle @auth {
        reverse_proxy 127.0.0.1:9091
      }
    '';
    # services.caddy = {
    #   virtualHosts."auth.${cfg.domain}".extraConfig = ''
    #     # Proxy verso Authelia
    #     reverse_proxy 127.0.0.1:9091

    #     tls {
    #       dns duckdns {$DUCKDNS_TOKEN}
    #     }
    #   '';
    # };
  };
}
