{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Roberto Lorenzon";
    userEmail = "roberto.lorenzon.2001@gmail.com";
    extraConfig = {
      init = {
        defaultBranch = "main";  
      };
    };
  };
}
