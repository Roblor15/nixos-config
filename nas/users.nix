{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myNas.users;

  # Define your users with their quotas
  # Note: 'zfs_dataset' has been removed as users no longer have generic storage
  nasUsers = {
    roberto = {
      email = "roberto.lorenzon.2001@gmail.com";
      quota = "1T";
      uid = "roberto";
    };
    maria = {
      email = "maria@example.com";
      quota = "500G";
      uid = "maria";
    };
    giuseppe = {
      email = "giuseppe@example.com";
      quota = "500G";
      uid = "giuseppe";
    };
    family = {
      email = "family@example.com";
      quota = "2T";
      uid = "family";
    };
  };
in
{
  options.myNas.users = {
    enable = lib.mkEnableOption "Enable per-user aggregated quota monitoring";
    users = lib.mkOption {
      type = lib.types.attrs;
      default = nasUsers;
      description = "NAS users configuration with quotas";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Daily Timer
    systemd.timers.quota-monitor = {
      description = "Daily quota check for Services";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "08:00:00";
        Persistent = true;
      };
    };

    # 2. The Service Logic
    systemd.services.quota-monitor = {
      description = "Check aggregated quotas (Seafile, Immich, Ente) and alert";
      path = with pkgs; [
        podman
        postgresql # Required for psql to query Immich/Ente
        gnugrep
      ];

      script =
        let
          usersJson = builtins.toJSON (
            lib.mapAttrs (name: value: {
              email = value.email;
              quota = value.quota;
            }) nasUsers
          );
          # Path to Seafile DB password (ensure this matches seafile.nix)
          seafileDbPass = config.age.secrets.seafile_db_admin_password.path;
        in
        ''
          ${pkgs.python3}/bin/python3 ${pkgs.writeText "check_quota.py" ''
            import json
            import subprocess
            import sys
            import os

            # --- CONFIGURATION ---
            USERS = json.loads('${usersJson}')
            SEAFILE_DB_PASS_FILE = "${seafileDbPass}"
            ALERT_THRESHOLD = 0.90 

            # --- HELPERS ---

            def parse_size(size_str):
                units = {"K": 1024, "M": 1024**2, "G": 1024**3, "T": 1024**4}
                size_str = size_str.upper().strip()
                if size_str[-1] in units:
                    return int(float(size_str[:-1]) * units[size_str[-1]])
                return int(size_str)

            def get_seafile_usage(email):
                """Queries Seafile MariaDB (via Podman)"""
                # Seafile stores usage in UserQuotaUsage table
                query = f"SELECT usage FROM UserQuotaUsage WHERE user = '{email}';"
                cmd = [
                    "podman", "exec", "-i", "seafile-db", 
                    "mariadb", "-u", "root", f"-p{open(SEAFILE_DB_PASS_FILE).read().strip()}",
                    "-D", "seahub_db", "-N", "-e", query
                ]
                try:
                    res = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
                    return int(res) if res else 0
                except Exception:
                    return 0

            def get_immich_usage(email):
                """Queries Immich Postgres (Local socket)"""
                # Sums up asset sizes for the specific user
                query = f"""
                    SELECT COALESCE(SUM(size), 0) 
                    FROM assets a 
                    JOIN users u ON a."ownerId" = u.id 
                    WHERE u.email = '{email}';
                """
                # We run as root, so we sudo to postgres user to execute
                cmd = [
                    "sudo", "-u", "postgres", 
                    "psql", "-d", "immich", "-t", "-c", query
                ]
                try:
                    res = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
                    return int(res) if res else 0
                except Exception:
                    return 0

            def get_ente_usage(email):
                """Queries Ente Postgres (Local socket)"""
                # Assumes Ente DB is named 'ente' and has 'usage' in users table
                query = f"SELECT usage FROM users WHERE email = '{email}';"
                cmd = [
                    "sudo", "-u", "postgres", 
                    "psql", "-d", "ente", "-t", "-c", query
                ]
                try:
                    res = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
                    return int(res) if res else 0
                except Exception:
                    return 0

            def send_alert(user, email, used_gb, total_gb, details):
                msg = (f"Subject: NAS QUOTA WARNING: {user}\n\n"
                       f"User {user} ({email}) has used {used_gb:.2f} GB of {total_gb} GB "
                       f"({used_gb/total_gb*100:.1f}%).\n\n"
                       f"Details:\n{details}")
                print(msg) 
                # Uncomment to enable email sending via msmtp:
                # subprocess.run(["msmtp", email], input=msg.encode())

            # --- MAIN LOGIC ---

            for user, data in USERS.items():
                limit_bytes = parse_size(data['quota'])
                
                # 1. Collect Usage from Services
                sea_bytes = get_seafile_usage(data['email'])
                immich_bytes = get_immich_usage(data['email'])
                ente_bytes = get_ente_usage(data['email'])
                
                # Note: RustFS is not checked here as it does not easily map to email users 
                # without API access, but Ente (which sits on top) is checked.

                total_bytes = sea_bytes + immich_bytes + ente_bytes
                
                # 2. Status Report
                usage_str = (f"  - Seafile: {sea_bytes/1024**3:.2f} GB\n"
                             f"  - Immich:  {immich_bytes/1024**3:.2f} GB\n"
                             f"  - Ente:    {ente_bytes/1024**3:.2f} GB")
                             
                print(f"User {user}: {total_bytes/1024**3:.2f}GB / {limit_bytes/1024**3}GB")
                
                # 3. Alert
                ratio = total_bytes / limit_bytes if limit_bytes > 0 else 0
                if ratio >= ALERT_THRESHOLD:
                    send_alert(user, data['email'], total_bytes/1024**3, limit_bytes/1024**3, usage_str)

          ''}
        '';
    };
  };
}
