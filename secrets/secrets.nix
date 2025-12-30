let
  roblor-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/sr4SCrEhqqGnBOGyhD+NJqW8kKyri1/EOVGoSivTV roblor@roblor-desktop";
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6aOobeUf7QSSnL9N7zDuvdUaRT++IPTbrxPZySh7V root@roblor-desktop";
  _matebook = "";
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGFjVBBP3j2adOF9UxjnqUHXxuvDQRF0ixlVyRSty73O root@roblor-nas";
in
{
  "authelia_jwt.age".publicKeys = [ nas roblor-desktop ];
  "authelia_session.age".publicKeys = [ nas roblor-desktop ];
  "authelia_storage.age".publicKeys = [ nas roblor-desktop ];
  "authelia_oidc_hmac.age".publicKeys = [ nas roblor-desktop ];
  "authelia_oidc_key.age".publicKeys = [ nas roblor-desktop ];
  "lldap_jwt.age".publicKeys = [ nas roblor-desktop ];
  "lldap_password.age".publicKeys = [ nas roblor-desktop ];
  "netbird_key.age".publicKeys = [ nas roblor-desktop ];
  "immich_oauth.age".publicKeys = [ nas roblor-desktop ];
  "duckdns_key.age".publicKeys = [ nas roblor-desktop ];
  "seafile_oauth.age".publicKeys = [ nas roblor-desktop ];
  "seafile_db_admin_password.age".publicKeys = [ nas roblor-desktop ];
  "seafile_db_user_password.age".publicKeys = [ nas roblor-desktop ];
  "seafile_admin_password.age".publicKeys = [ nas roblor-desktop ];
  "seafile_redis_password.age".publicKeys = [ nas roblor-desktop ];
  "seadoc_jwt.age".publicKeys = [ nas roblor-desktop ];
  "brevo_password.age".publicKeys = [ nas roblor-desktop ];
  "ente_smtp.age".publicKeys = [ nas roblor-desktop ];
}
