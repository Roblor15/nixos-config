{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Roberto Lorenzon";
    userEmail = "roberto.lorenzon.2001@gmail.com";
    extraConfig = {
      user = {
        signingKey = "~/.ssh/github_signing_ed25519";
      };
      init = {
        defaultBranch = "main";  
      };
      gpg = {
        format ="ssh";
      };
      commit = {
        gpgsign = true;
      };
      tag = {
        gpgsign = true;
      };
      core = {
        filemode = true;
        sshCommand = "ssh -i ~/.ssh/github_ed25519";
      };
    };
  };
}
