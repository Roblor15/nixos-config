{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH=$PATH:~/.cargo/bin

      eval "$(starship init bash)"
      eval "$(rustic completions bash 2> /dev/null)" 

      alias backup-data="borg create --stats --progress --compression auto,lzma,9 --patterns-from ~/borg-dati-patterns.lst /run/media/roblor/Roblor\'s\ Files/borg-backup::Dati-{now:%Y-%m-%dT%H:%M:%S}"
      alias backup-home="borg create --stats --progress --compression auto,lzma,9 --patterns-from ~/borg-home-patterns.lst /run/media/roblor/Roblor\'s\ Files/borg-backup::Home-{now:%Y-%m-%dT%H:%M:%S}"
      alias esp-idf="nix develop github:mirrexagon/nixpkgs-esp-dev#esp32-idf"
      alias clean-generations="sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2"
    '';
  };
}
