{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Roberto Lorenzon";
    userEmail = "roberto.lorenzon.2001@gmail.com";
    extraConfig = {
      user = {
        signingKey = "~/.ssh/id_rsa.pub";
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
      };
    };
  };
}
