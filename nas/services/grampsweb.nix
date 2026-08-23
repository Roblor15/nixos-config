{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.grampsweb;

  # Riproduciamo la logica del <<: *grampsweb di Docker Compose
  sharedEnvironment = {
    GRAMPSWEB_TREE = "Gramps Web";
    GRAMPSWEB_CELERY_CONFIG__broker_url = "redis://grampsweb_redis:6379/0";
    GRAMPSWEB_CELERY_CONFIG__result_backend = "redis://grampsweb_redis:6379/0";
    GRAMPSWEB_RATELIMIT_STORAGE_URI = "redis://grampsweb_redis:6379/1";
  };

  # Ho aggiornato i percorsi esattamente come nel tuo docker-compose
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
    
    # 1. Reverse Proxy Caddy
    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      @grampsweb host gramps.${cfg.domain}
      handle @grampsweb {
        reverse_proxy 127.0.0.1:8889
      }
    '';

    # 2. Creazione automatica delle cartelle persistenti sul NAS
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

    # 3. Creazione della Rete Podman (Necessaria per DNS tra container)
    systemd.services.init-grampsweb-network = {
      description = "Crea rete podman per Grampsweb";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.podman}/bin/podman network exists grampsweb-net || ${pkgs.podman}/bin/podman network create grampsweb-net
      '';
    };

    # Assicuriamoci che i container partano SOLO dopo aver creato la rete
    systemd.services."podman-grampsweb".requires = [ "init-grampsweb-network.service" ];
    systemd.services."podman-grampsweb".after = [ "init-grampsweb-network.service" ];
    systemd.services."podman-grampsweb_celery".requires = [ "init-grampsweb-network.service" ];
    systemd.services."podman-grampsweb_celery".after = [ "init-grampsweb-network.service" ];
    systemd.services."podman-grampsweb_redis".requires = [ "init-grampsweb-network.service" ];
    systemd.services."podman-grampsweb_redis".after = [ "init-grampsweb-network.service" ];

    # 4. Containers
    virtualisation.oci-containers = {
      backend = "podman";
      
      containers = {
        # Valkey/Redis
        grampsweb_redis = {
          image = "docker.io/valkey/valkey:8-alpine";
          autoStart = true;
          extraOptions = [ "--network=grampsweb-net" ];
        };

        # App Principale
        grampsweb = {
          image = "ghcr.io/gramps-project/grampsweb:latest";
          autoStart = true;
          # Modificata rispetto al docker-compose (80:5000) per servire Caddy sulla 8889 locale
          ports = [ "127.0.0.1:8889:5000" ];
          environment = sharedEnvironment;
          volumes = sharedVolumes;
          dependsOn = [ "grampsweb_redis" ];
          extraOptions = [ "--network=grampsweb-net" ];
        };

        # Celery Worker
        grampsweb_celery = {
          image = "ghcr.io/gramps-project/grampsweb:latest";
          autoStart = true;
          # In Nix, il comando va diviso in un array di stringhe
          cmd = [ "celery" "-A" "gramps_webapi.celery" "worker" "--loglevel=INFO" "--concurrency=2" ];
          environment = sharedEnvironment;
          volumes = sharedVolumes;
          dependsOn = [ "grampsweb" "grampsweb_redis" ];
          extraOptions = [ "--network=grampsweb-net" ];
        };
      };
    };
  };
}
