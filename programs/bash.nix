{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH=$PATH:~/.cargo/bin
      eval "$(rustic completions bash 2> /dev/null)" 
      alias clean-generations="sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2"
      if [[ $- == *i* ]]; then
        eval "$(starship init bash)"
    '';
  };
}
