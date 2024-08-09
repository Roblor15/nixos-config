{ config, /* unstable, */ inputs, pkgs, ... }:

{
  imports = [
    ./programs/alacritty.nix
    ./programs/anyrun.nix
    ./programs/bash.nix
    ./programs/git.nix
    ./programs/helix.nix
    ./programs/fish.nix
    ./programs/rustic.nix
    ./programs/hyprland/hyprland.nix
    ./programs/vscode.nix
    ./programs/mako.nix
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
    firefox
    google-chrome
    cryptsetup
    gcc
    tdesktop
    nodejs
    tree-sitter
    ripgrep
    fd
    bibata-cursors
    spotify
    zoom-us
    lm_sensors
    starship
    onlyoffice-bin
    wlsunset
    eww
    ddcutil
    rustic-rs
    libva-utils
    profile-sync-daemon
    audacity
    zoxide
    nix-your-shell
    clang-tools
    rust-analyzer
    nil
    taplo
    cachix
    gparted
    nodePackages.bash-language-server
    cargo-generate
    quickemu
    mako
    hypridle
    hyprlock
    hyprpaper
    tor-browser
    wl-clipboard
    # unstable.cliphist
    # unstable.wluma
    cliphist
    wluma
    jq
    socat
    inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    # grimblast
    kicad
    cinnamon.nemo
    # hyprutils
  ];

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Amber";
    size = 24;
  };

  # gtk = {
  #   enable = true;
  #   cursorTheme = {
  #     package = pkgs.bibata-cursors;
  #     name = "Bibata-Modern-Amber";
  #     size = 24;
  #   };
  # };

# gtk = {
#   enable = true;
#   theme = {
#     package = pkgs.flat-remix-gtk;
#     name = "Flat-Remix-GTK-Grey-Darkest";
#   };

#   iconTheme = {
#     package = pkgs.gnome.adwaita-icon-theme;
#     name = "Adwaita";
#   };

#   font = {
#     name = "Sans";
#     size = 11;
#   };
# };

  services.mpris-proxy.enable = true;
}
