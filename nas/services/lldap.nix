{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.lldap;
in
{
  options.myNas.services.lldap = {
    enable = lib.mkEnableOption "LLDAP User Management";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Il tuo dominio";
    };
    baseDn = lib.mkOption {
      type = lib.types.str;
      description = "Traduzione LDAP del dominio";
    };
  };

  config = lib.mkIf cfg.enable {
    # Forza la creazione del gruppo lldap
    users.groups.lldap = {};
    
    # Assicura che l'utente lldap (del servizio) faccia parte del gruppo
    users.users.lldap = {
      isSystemUser = true;
      group = "lldap";
    };
    age.secrets = {
      lldap_jwt = {
        file = ../../secrets/lldap_jwt.age;
        owner = "lldap";
      };
      lldap_password = {
        file = ../../secrets/lldap_password.age;
        owner = "lldap";
      };
    };

    services.lldap = {
      enable = true;
      settings = {
        ldap_base_dn = cfg.baseDn;
        ldap_port = 3890; # Porta per connessioni LDAP (usata da Authelia)
        http_port = 17170; # Interfaccia Web di gestione
        http_url = "https://ldap.${cfg.domain}";

        # Percorsi dei segreti
        # jwt_secret_file = config.age.secrets.lldap_jwt.path;

        # Questa opzione imposta la password dell'utente "admin" all'avvio
        ldap_user_email = "roberto.lorenzon@hotmail.it";
        ldap_user_pass_file = config.age.secrets.lldap_password.path;
        force_ldap_user_pass_reset = "always";
      };
    };

    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      # Definisci il matcher solo per "auth"
      @ldap host ldap.${cfg.domain}
      
      # Gestisci la richiesta
      handle @ldap {
        reverse_proxy 127.0.0.1:17170
      }
    '';
    # services.caddy.virtualHosts."ldap.${cfg.domain}".extraConfig = ''
    #   # tls internal  # Usa la CA interna di Caddy per HTTPS locale
    #   reverse_proxy 127.0.0.1:17170
    #   tls {
    #     dns duckdns {$DUCKDNS_TOKEN}
    #   }
    # '';
  };
}
