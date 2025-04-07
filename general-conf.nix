{
  type ? "",
  hyprland ? true,
  pkgs,
  inputs,
}:
let
  laptopEnabled = if (type == "laptop") then true else false;
  desktopEnabled = if (type == "desktop") then true else false;

  common-packages = with pkgs; [
    firefox
    google-chrome
    cryptsetup
    gcc
    tdesktop
    ripgrep
    fd
    bibata-cursors
    spotify
    lm_sensors
    ddcutil
    profile-sync-daemon
    nix-your-shell
    nil
    taplo
    cachix
    nodePackages.bash-language-server
    quickemu
    tor-browser
    wl-clipboard
    cliphist
    wluma
    jq
    socat
    grimblast
    nemo
    ethtool
    inputs.zen-browser.packages."${pkgs.system}".specific
  ];
in
{
  laptop.enable = laptopEnabled;
  desktop.enable = desktopEnabled;
  gnome = laptopEnabled;
  hyprland = hyprland;
  eww = hyprland;
  mako = hyprland;
  hyprlock = hyprland;
  hyprpanel = hyprland;
  hypridle = hyprland;

  rustic = true;
  wezterm = true;
  alacritty = false;
  zathura = true;
  fish = true;
  bash = true;
  starship = true;

  packages = common-packages // (with pkgs; if laptopEnabled then [
    firefox
    google-chrome
    cryptsetup
    gcc
    # tdesktop
    # nodejs
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
    # inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    grimblast
    # kicad
    nemo
    # hyprutils
    ethtool
    darktable
    mattermost-desktop
    inputs.zen-browser.packages."${pkgs.system}".specific
    teams-for-linux
    # unstable.probe-rs-tools
  ] else [
    
  ]);
}

# let
#   config = import ./your-file.nix { 
#     laptopEnable = true; 
#     hyprlandEnable = false;
#   };
# in
# config

# baseConfig // { fish = false; }  # Override `fish` to false
