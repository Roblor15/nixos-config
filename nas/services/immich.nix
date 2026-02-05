{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.immich;
in
{
  options.myNas.services.immich = {
    enable = lib.mkEnableOption "Abilita Immich Photo Server";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio per accedere a immich";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.immich_oauth = {
      file = ../../secrets/immich_oauth.age;
      owner = "immich";
      group = "immich";
    };

    services.immich = {
      enable = true;
      host = "127.0.0.1";
      port = 2283;
      secretsFile = config.age.secrets.immich_oauth.path;

      mediaLocation = "/mnt/hdd/immich";
    };

    # 2. Integrazione Authelia (Forward Auth)
    # Blocca qualsiasi richiesta e chiedi ad Authelia se l'utente è loggato
    # forward_auth 127.0.0.1:9091 {
    #   uri /api/verify?rd=${cfg.authUrl}
    #   copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
    # }
    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      # Definisci il matcher solo per "auth"
      @immich host immich.${cfg.domain}

      # Gestisci la richiesta
      handle @immich {
        reverse_proxy 127.0.0.1:2283
      }
    '';
  };
}
