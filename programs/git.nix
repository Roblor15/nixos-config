{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Roberto Lorenzon";
        email = "roberto.lorenzon.2001@gmail.com";
        signingKey = "~/.ssh/github_signing_ed25519";
      };
      init = {
        defaultBranch = "main";
      };
      gpg = {
        format = "ssh";
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
