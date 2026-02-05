{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.myNas.services.onlyoffice;
  unstablePkgs = import inputs.unstable {
    system = pkgs.system;
    config = {
      allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "corefonts"
        ];
    };
  };
in
{
  disabledModules = [ "services/web-apps/onlyoffice.nix" ];
  imports = [
    ./modules/onlyoffice.nix
  ];

  options.myNas.services.onlyoffice = {
    enable = lib.mkEnableOption "Abilita OnlyOffice Server";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio per accedere a OnlyOffice";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.onlyoffice_jwt = {
      file = ../../secrets/onlyoffice_jwt.age;
      owner = "onlyoffice";
      group = "onlyoffice";
      mode = "440";
    };
    age.secrets.onlyoffice_nonce = {
      file = ../../secrets/onlyoffice_nonce.age;
      owner = "onlyoffice";
      group = "onlyoffice";
      mode = "440";
    };
    services.onlyoffice = {
      enable = true;
      # Use the actual domain so Host header matching works
      # hostname = "localhost";
      hostname = "onlyoffice.${cfg.domain}";
      # jwtSecretFile = config.age.secrets.onlyoffice_jwt.path;
      jwtSecretFile = "${pkgs.writeText "onlyoffice-jwt" "ciaociao"}";
      securityNonceFile = config.age.secrets.onlyoffice_nonce.path;

      package = unstablePkgs.onlyoffice-documentserver;
      # x2t = unstablePkgs.x2t;
      wopi = true;
    };

    # Make the OnlyOffice Nginx vhost listen on 127.0.0.1:9005 instead of default ports
    users.users.nginx.extraGroups = [ "onlyoffice" ];
    services.nginx.enable = true;
    services.nginx.virtualHosts."onlyoffice.${cfg.domain}" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 9005;
        }
      ];
      forceSSL = false;
      enableACME = false;
      # extraConfig = ''
      #   set_real_ip_from 127.0.0.1;
      #   real_ip_header X-Real-IP;
      #   real_ip_recursive on;
      # '';
      # locations."/".extraConfig = ''
      #   proxy_set_header X-Forwarded-Proto https;
      #   proxy_set_header X-Forwarded-Host $host;
      # '';
    };

    # Configure Caddy to proxy to Nginx
    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      @onlyoffice host onlyoffice.${cfg.domain}

      handle @onlyoffice {
        reverse_proxy 127.0.0.1:9005 {
          # Pass through the original Host header
          header_up Host {host}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-Proto https
          header_up X-Forwarded-Host {host}
        }
      }
    '';
  };
}
