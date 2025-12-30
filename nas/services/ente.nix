{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.ente;

  # Reference to the web config from the upstream module
  cfgWeb = config.services.ente.web;

  # Function to create web packages with correct env vars
  webPackage =
    enteApp:
    cfgWeb.package.override {
      inherit enteApp;
      enteMainUrl = "https://${cfgWeb.domains.photos}";
      extraBuildEnv = {
        NEXT_PUBLIC_ENTE_ENDPOINT = "https://${cfgWeb.domains.api}";
        NEXT_PUBLIC_ENTE_ALBUMS_ENDPOINT = "https://${cfgWeb.domains.albums}";
        NEXT_TELEMETRY_DISABLED = "1";
      };
    };
in
{
  options.myNas.services.ente = {
    enable = lib.mkEnableOption "Abilita Ente Photos Server";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio base per accedere a ente";
      example = "example.com";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.ente_smtp = {
      file = ../../secrets/ente_smtp.age;
    };

    systemd.services.ente.serviceConfig.EnvironmentFile = config.age.secrets.ente_smtp.path;
    # Configurazione API Backend
    services.ente.api = {
      enable = true;
      domain = "api-ente.${cfg.domain}";
      enableLocalDB = true;
      user = "ente";
      group = "ente";
      nginx.enable = false;

      settings = {
        smtp = {
          host = "smtp-relay.brevo.com";
          port = 587;
          username = "9ecdc8001@smtp-brevo.com"; # Same as in your msmtp config
          email = "roberto.lorenzon.2001@gmail.com"; # Must match your verified sender
          smtp.sender-name = "Ente - Lorenzon NAS";
        };

        s3 = {
          use_path_style_urls = true;
          b2-eu-cen = {
            endpoint = "https://rustfs.${cfg.domain}";
            region = "us-east-1";
            bucket = "ente";
            key._secret = pkgs.writeText "s3_key" "rustfsadmin";
            secret._secret = pkgs.writeText "s3_secret" "rustfsadmin";
          };
        };

        key = {
          encryption._secret = pkgs.writeText "enc_key" "3OYFclGvFlKyrBhwSgameHkbbgU4wmzQRZpivuSBbh0=";
          hash._secret = pkgs.writeText "hash_key" "3OYFclGvFlKyrBhwSgameHkbbgU4wmzQRZpivuSBbh0=";
        };

        jwt = {
          secret._secret = pkgs.writeText "jwt_secret" "3OYFclGvFlKyrBhwSgameHkbbgU4wmzQRZpivuSBbh0=";
        };

        apps = {
          public-albums = "https://albums-ente.${cfg.domain}";
          cast = "https://cast-ente.${cfg.domain}";
          accounts = "https://accounts-ente.${cfg.domain}";
        };

        http.use-tls = false;
      };
    };

    # Configurazione Web Frontend
    services.ente.web = {
      enable = true;
      domains = {
        photos = "photos-ente.${cfg.domain}";
        cast = "cast-ente.${cfg.domain}";
        api = "api-ente.${cfg.domain}";
        albums = "albums-ente.${cfg.domain}";
        accounts = "accounts-ente.${cfg.domain}";
      };
    };

    # Disable nginx completely
    services.nginx.enable = lib.mkForce false;

    # Individual vhosts for each subdomain (more reliable than wildcard)
    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      @photos host  ${cfgWeb.domains.photos}
      @albums host ${cfgWeb.domains.albums}
      @accounts host ${cfgWeb.domains.accounts}
      @cast host ${cfgWeb.domains.cast}
      @api host ${cfgWeb.domains.api}

      handle @photos {
          root * ${webPackage "photos"}
          encode zstd gzip
          file_server
          try_files {path} {path}.html /index.html
          header Access-Control-Allow-Origin "https://${cfgWeb.domains.api}"
          header Access-Control-Allow-Methods "GET, POST, OPTIONS"
          header Access-Control-Allow-Headers "Content-Type"
      }

      handle @albums {
          root * ${webPackage "photos"}
          encode zstd gzip
          file_server
          try_files {path} {path}.html /index.html
          header Access-Control-Allow-Origin "https://${cfgWeb.domains.api}"
          header Access-Control-Allow-Methods "GET, POST, OPTIONS"
          header Access-Control-Allow-Headers "Content-Type"
      }

      handle @accounts {
          root * ${webPackage "accounts"}
          encode zstd gzip
          file_server
          try_files {path} {path}.html /index.html
          header Access-Control-Allow-Origin "https://${cfgWeb.domains.api}"
          header Access-Control-Allow-Methods "GET, POST, OPTIONS"
          header Access-Control-Allow-Headers "Content-Type"
      }

      handle @cast {
          root * ${webPackage "cast"}
          encode zstd gzip
          file_server
          try_files {path} {path}.html /index.html
          header Access-Control-Allow-Origin "https://${cfgWeb.domains.api}"
          header Access-Control-Allow-Methods "GET, POST, OPTIONS"
          header Access-Control-Allow-Headers "Content-Type"
      }


      # API Backend
      handle @api {
          reverse_proxy 127.0.0.1:8080
      }
    '';
  };
}
