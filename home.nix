{ config, pkgs, ... }:

{
  imports = [
    ./programs/alacritty.nix
    ./programs/bash.nix
    ./programs/git.nix
    ./programs/helix.nix
    ./programs/fish.nix
  ];
  
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "roblor";
  home.homeDirectory = "/home/roblor";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  home.packages = with pkgs; [
    tiramisu
    profile-sync-daemon
    audacity
    google-chrome
    zoxide
    nix-your-shell
    clang-tools
    rust-analyzer
    nodePackages.bash-language-server
  ];

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Amber";
      size = 24;
    };
  };
}
