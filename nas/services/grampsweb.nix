{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.grampsweb;

  sharedEnvironment = {
    GRAMPSWEB_TREE = "Gramps Web";
    GRAMPSWEB_CELERY_CONFIG__broker_url = "redis://grampsweb_redis:6379/0";
    GRAMPSWEB_CELERY_CONFIG__result_backend = "redis://grampsweb_redis:6379/0";
    GRAMPSWEB_RATELIMIT_STORAGE_URI = "redis://grampsweb_redis:6379/1";
    
    # Configurazioni Authelia OIDC (Senza mappatura ruoli)
    GRAMPSWEB_BASE_URL = "https://gramps.${cfg.domain}";
    GRAMPSWEB_OIDC_ENABLED = "True";
    GRAMPSWEB_OIDC_ISSUER = "https://auth.${cfg.domain}";
    GRAMPSWEB_OIDC_NAME = "Authelia";
    GRAMPSWEB_OIDC_CLIENT_ID = "grampsweb";
    GRAMPSWEB_OIDC_SCOPES = "openid email profile groups";

    GRAMPSWEB_OIDC_ROLE_CLAIM = "groups";
    GRAMPSWEB_OIDC_GROUP_ADMIN = "gramps_admin";
    GRAMPSWEB_OIDC_GROUP_OWNER = "gramps_owner"; 
    GRAMPSWEB_OIDC_GROUP_EDITOR = "gramps_editor"; 
    GRAMPSWEB_OIDC_GROUP_MEMBER = "gramps_member"; 
    GRAMPSWEB_OIDC_GROUP_GUEST = "gramps_guest";
  };

  sharedVolumes = [
    "/var/lib/grampsweb/users:/app/users"
    "/var/lib/grampsweb/indexdir:/app/indexdir"
    "/var/lib/grampsweb/thumbnail_cache:/app/thumbnail_cache"
    "/var/lib/grampsweb/cache:/app/cache"
    "/var/lib/grampsweb/secret:/app/secret"
    "/var/lib/grampsweb/grampsdb:/root/.gramps/grampsdb"
    "/var/lib/grampsweb/media:/app/media"
    "/var/lib/grampsweb/tmp:/tmp"
  ];

in
{
  options.myNas.services.grampsweb = {
    enable = lib.mkEnableOption "Abilita grampsweb service";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio per accedere a grampsweb";
    };
  };

  config = lib.mkIf cfg.enable {
    
    # Gestione del segreto con agenix (crea il file secrets/grampsweb_oidc.age)
    age.secrets.grampsweb_oidc = {
      file = ../../secrets/grampsweb_oidc.age;
      # Il container podman lo leggerà all'avvio
    };

    # Reverse Proxy Caddy
    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      @grampsweb host gramps.${cfg.domain}
      handle @grampsweb {
        reverse_proxy 127.0.0.1:8889
      }
    '';

    # Creazione automatica delle cartelle persistenti sul NAS
    systemd.tmpfiles.rules = [
      "d /var/lib/grampsweb/users 0755 root root -"
      "d /var/lib/grampsweb/indexdir 0755 root root -"
      "d /var/lib/grampsweb/thumbnail_cache 0755 root root -"
      "d /var/lib/grampsweb/cache 0755 root root -"
      "d /var/lib/grampsweb/secret 0755 root root -"
      "d /var/lib/grampsweb/grampsdb 0755 root root -"
      "d /var/lib/grampsweb/media 0755 root root -"
      "d /var/lib/grampsweb/tmp 0755 root root -"
    ];

    # Creazione della Rete Podman
    systemd.services.init-grampsweb-network = {
      description = "Crea rete podman per Grampsweb";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.podman}/bin/podman network exists grampsweb-net || ${pkgs.podman}/bin/podman network create grampsweb-net
      '';
    };

    systemd.services."podman-grampsweb".requires = [ "init-grampsweb-network.service" ];
    systemd.services."podman-grampsweb".after = [ "init-grampsweb-network.service" ];
    systemd.services."podman-grampsweb_celery".requires = [ "init-grampsweb-network.service" ];
    systemd.services."podman-grampsweb_celery".after = [ "init-grampsweb-network.service" ];
    systemd.services."podman-grampsweb_redis".requires = [ "init-grampsweb-network.service" ];
    systemd.services."podman-grampsweb_redis".after = [ "init-grampsweb-network.service" ];

    # Containers
    virtualisation.oci-containers = {
      backend = "podman";
      
      containers = {
        grampsweb_redis = {
          image = "docker.io/valkey/valkey:8-alpine";
          autoStart = true;
          extraOptions = [ "--network=grampsweb-net" ];
        };

        grampsweb = {
          image = "ghcr.io/gramps-project/grampsweb:latest";
          autoStart = true;
          ports = [ "127.0.0.1:8889:5000" ];
          environment = sharedEnvironment;
          volumes = sharedVolumes;
          dependsOn = [ "grampsweb_redis" ];
          extraOptions = [ "--network=grampsweb-net" ];
          environmentFiles = [ config.age.secrets.grampsweb_oidc.path ];
        };

        grampsweb_celery = {
          image = "ghcr.io/gramps-project/grampsweb:latest";
          autoStart = true;
          cmd = [ "celery" "-A" "gramps_webapi.celery" "worker" "--loglevel=INFO" "--concurrency=2" ];
          environment = sharedEnvironment;
          volumes = sharedVolumes;
          dependsOn = [ "grampsweb" "grampsweb_redis" ];
          extraOptions = [ "--network=grampsweb-net" ];
          environmentFiles = [ config.age.secrets.grampsweb_oidc.path ];
        };
      };
    };
  };
}
