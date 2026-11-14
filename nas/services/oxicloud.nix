{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.oxicloud;
in
{
  options.myNas.services.oxicloud = {
    enable = lib.mkEnableOption "Abilita OxiCloud";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio base per accedere a OxiCloud";
      example = "example.com";
    };
  };

  config = lib.mkIf cfg.enable {
    # Decommenta se in futuro vorrai gestire password segrete tramite sops/agenix
    age.secrets.oxicloud_env = {
      file = ../../secrets/oxicloud-env.age;
    };

    systemd.tmpfiles.settings = {
      "oxicloud" = {
        "/mnt/hdd/oxicloud/data" = {
          d = {
            mode = "0750";
            user = "root";
            group = "root";
          };
        };
        "/mnt/hdd/oxicloud/db" = {
          d = {
            mode = "0750";
            user = "root";
            group = "root";
          };
        };
      };
    };

    systemd.services."podman-network-oxicloud_net" = {
      description = "Crea la rete Podman per OxiCloud";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      before = [ "podman-oxicloud-db.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Il trattino iniziale dice a systemd di ignorare eventuali errori (es. se la rete esiste già)
        ExecStart = "-${pkgs.podman}/bin/podman network create oxicloud_net";
      };
    };

    virtualisation.oci-containers = {
      containers = {
        oxicloud-db = {
          image = "postgres:18.2-alpine3.23";

          volumes = [
            "/mnt/hdd/oxicloud/db:/var/lib/postgresql/data"
          ];

          environment = {
            POSTGRES_DB = "oxicloud";
            POSTGRES_USER = "postgres";
            POSTGRES_PASSWORD = "postgres";
          };

          # ports = [
          #   "127.0.0.1:5432:5432"
          # ];

          extraOptions = [
            "--network=oxicloud_net"
          ];
        };

        oxicloud = {
          image = "diocrafts/oxicloud:latest";

          volumes = [
            "/mnt/hdd/oxicloud/data:/app/storage"
          ];

          environment = {
            OXICLOUD_SERVER_HOST = "0.0.0.0";
            OXICLOUD_SERVER_PORT = "8086";
            OXICLOUD_BASE_URL = "https://oxicloud.${cfg.domain}";
            OXICLOUD_STORAGE_PATH = "/app/storage";
            OXICLOUD_DB_CONNECTION_STRING = "postgres://postgres:postgres@oxicloud-db:5432/oxicloud";
            OXICLOUD_OIDC_PROVIDER_NAME = "Authelia";
            OXICLOUD_OIDC_ISSUER_URL = "https://auth.${cfg.domain}";
            OXICLOUD_OIDC_CLIENT_ID = "oxicloud";
            # OXICLOUD_OIDC_CLIENT_SECRET = "your-client-secret";
            OXICLOUD_WOPI_ENABLED = "true";
            # Usa l'URL pubblico che passa per Caddy
            OXICLOUD_WOPI_DISCOVERY_URL = "https://onlyoffice.${cfg.domain}/hosting/discovery";
            OXICLOUD_WOPI_PUBLIC_BASE_URL = "https://oxicloud.${cfg.domain}";

            OXICLOUD_NEXTCLOUD_ENABLED = "true";

            OXICLOUD_JOBS_NOTIFY_EMAIL_TO = "roberto.lorenzon.2001@gmail.com";

            OXICLOUD_SMTP_HOST = "smtp-relay.brevo.com";
            OXICLOUD_SMTP_PORT = "587";
            OXICLOUD_SMTP_USER = "9ecdc8001@smtp-brevo.com";
            OXICLOUD_SMTP_FROM = "Oxicloud <roberto.lorenzon.2001@gmail.com>";
          };

          environmentFiles = [ config.age.secrets.oxicloud_env.path ];

          ports = [
            "127.0.0.1:8086:8086"
          ];

          extraOptions = [
            "--network=oxicloud_net"
          ];

          dependsOn = [
            "oxicloud-db"
          ];
        };
      };
    };

    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      @oxicloud host oxicloud.${cfg.domain}

      handle @oxicloud {
        reverse_proxy 127.0.0.1:8086
      }
    '';
  };
}
