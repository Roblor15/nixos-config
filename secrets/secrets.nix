let
  roblor-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/sr4SCrEhqqGnBOGyhD+NJqW8kKyri1/EOVGoSivTV roblor@roblor-desktop";
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6aOobeUf7QSSnL9N7zDuvdUaRT++IPTbrxPZySh7V root@roblor-desktop";
  _matebook = "";
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBe36BHVW0IE5NZL2jTqntA/qdOMi+Hupazq3fcvF/rk root@roblor-nas";
  zimaboard = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7KsEuec8IKirs4umLqOybI8ofMch4NoW/1M3akUuSa root@roblor-zimaboard";
  vps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7ko1Hnkmv1v6B9ateXoM5KilWoZjSlocoJelZVnRJW root@localhost";
in
{
  "authelia_jwt.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "authelia_session.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "authelia_storage.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "authelia_oidc_hmac.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "authelia_oidc_key.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "lldap_jwt.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "lldap_password.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "netbird_key.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "immich_oauth.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "duckdns_key.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
    vps
  ];
  "dynu_env.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
    vps
  ];
  "seafile_oauth.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "seafile_db_admin_password.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "seafile_db_user_password.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "seafile_admin_password.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "seafile_redis_password.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "seadoc_jwt.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "brevo_password.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "ente_smtp.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "opencloud_env.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "onlyoffice_jwt.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "onlyoffice_nonce.age".publicKeys = [
    nas
    roblor-desktop
    zimaboard
  ];
  "vps-wg-private.age".publicKeys = [
    roblor-desktop
    vps
  ];
  "nas-wg-private.age".publicKeys = [
    roblor-desktop
    nas
    zimaboard
  ];
  "rustfs_env.age".publicKeys = [
    roblor-desktop
    nas
    zimaboard
  ];
  "wg-preshared.age".publicKeys = [
    roblor-desktop
    nas
    vps
    zimaboard
  ];
}
