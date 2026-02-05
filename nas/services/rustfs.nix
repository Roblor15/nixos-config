{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.services.rustfs;
in
{
  options.myNas.services.rustfs = {
    enable = lib.mkEnableOption "Abilita RustFS S3 Object Storage";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio base per accedere a RustFS";
      example = "example.com";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.rustfs_env = {
      file = ../../secrets/rustfs_env.age;
    };
    virtualisation.oci-containers = {
      containers = {
        rustfs = {
          podman.user = "root";
          user = "root";
          image = "docker.io/rustfs/rustfs:1.0.0-alpha.76";

          # Map the local storage to the container
          volumes = [
            "/mnt/hdd/rustfs/data:/data"
          ];

          environmentFiles = [ config.age.secrets.rustfs_env.path ];

          # Environment variables (Strings only)
          environment = {
            RUSTFS_ADDRESS = "9000";
            # RUSTFS_ACCESS_KEY = "rustfsadmin";
            # RUSTFS_SECRET_KEY = "rustfsadmin";
            RUSTFS_CONSOLE_ENABLE = "true";
            # RUSTFS_SERVER_DOMAINS = domain;
          };

          ports = [
            "9000:9000" # API
            "9001:9001" # Web Console
          ];

          cmd = [
            "--address"
            ":9000"
            "--console-enable"
            # "--server-domains"
            # domain
            "--access-key"
            "rustfsadmin"
            "--secret-key"
            "rustfsadmin"
            "/data"
          ];
        };
      };
    };

    systemd.tmpfiles.settings = {
      "rustfs" = {
        "/mnt/hdd/rustfs/data" = {
          d = {
            mode = "0710"; # rwxr-x--- (Secure: only owner/group can read)
            user = "root";
            group = "root";
          };
        };
      };
    };

    services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
      @rustfs host rustfs.${cfg.domain}

      # Gestisci la richiesta
      handle @rustfs {
        reverse_proxy 127.0.0.1:9001
      }
    '';
  };
}
