{ config, pkgs, ... }:

{
  imports = [
    ./programs/alacritty.nix
    ./programs/bash.nix
    ./programs/git.nix
    ./programs/helix.nix
    ./programs/fish.nix
    ./programs/rustic.nix
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
    google-chrome
    cryptsetup
    vimPlugins.vim-plug
    fzf
    gcc
    tdesktop
    nodejs
    tree-sitter
    ripgrep
    python3Full
    gnumake
    fd
    bibata-cursors
    neovim
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    gnomeExtensions.system-monitor
    gnomeExtensions.compiz-windows-effect
    gnome.gnome-settings-daemon
    gnome.gnome-tweaks
    spotify
    zoom-us
    lm_sensors
    starship
    onlyoffice-bin
    wofi
    hyprpaper
    waybar
    mpvpaper
    # postman
    wlsunset
    swaylock-effects
    eww-wayland
    ddcutil
    wluma
    swayidle
    rustic-rs
    globalprotect-openconnect
    libva-utils
    tiramisu
    profile-sync-daemon
    audacity
    google-chrome
    zoxide
    nix-your-shell
    clang-tools
    rust-analyzer
    nil
    taplo
    cachix
    gparted
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

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.extraConfig = ''
    # monitor=eDP-1,3000x2000@60,530x1440,2
    monitor=eDP-1,3000x2000@60,0x1440,2
    monitor=DP-1,2560×1440@60,0x0,1
    monitor=DP-2,3440x1440,0x0,1

    workspace=eDP-1,1
    workspace=DP-1,2

    exec-once = hyprctl setcursor Bibata-Modern-Amber 24
    exec-once = hyprpaper
    exec-once = eww --config ~/.config/eww/bar open bar
    exec-once = wlsunset -l $(~/.config/hypr/position.fish --lat) -L $(~/.config/hypr/position.fish --lon) -t 3000

    exec-once = swayidle -w timeout 180 'swaylock -f -C ~/.config/swaylock/swaylock'
    exec-once = swayidle -w timeout 10 'if pgrep -x swaylock; then systemctl suspend; fi' before-sleep 'if ! pgrep -x swaylock; then swaylock -f -C ~/.config/swaylock/swaylock; fi'

    input {
        kb_layout = it
        kb_variant =
        kb_model =
        kb_options =
        kb_rules =

        follow_mouse = yes

        touchpad {
            natural_scroll = yes
        }

        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
    }

    device:magic-mouse-2 {
        sensitivity = -1
        natural_scroll = yes
    }

    device:virtual-mouse {
        sensitivity = -1
        natural_scroll = yes
    }

    device:keychron-k3 {
        kb_layout = us
    }

    device:keychron-keychron-k3-2 {
        kb_layout = us
    }
    
    device:keychron-keychron-k3 {
        kb_layout = us
    }

    general {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        gaps_in = 5
        gaps_out = 20
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)
        cursor_inactive_timeout = 10

        layout = dwindle
    }

    decoration {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        rounding = 10
        # blur = yes
        # blur_size = 3
        # blur_passes = 1
        # blur_new_optimizations = on

        drop_shadow = yes
        shadow_range = 4
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)
    }

    animations {
        enabled = yes

        # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier = myBezier, 0.05, 0.9, 0.1, 1.05

        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
    }

    dwindle {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = yes # you probably want this
    }

    master {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_is_master = true
    }

    gestures {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        workspace_swipe = true
    }

    # Example windowrule v1
    # windowrule = float, ^(kitty)$
    # Example windowrule v2
    # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
    # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


    # See https://wiki.hyprland.org/Configuring/Keywords/ for more
    $mainMod = SUPER

    # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
    bind = $mainMod, T, exec, alacritty
    bind = $mainMod, N, exec, alacritty -e nvim
    bind = $mainMod, B, exec, firefox
    bind = $mainMod, C, killactive,
    bind = $mainMod, M, exit,
    bind = $mainMod, V, togglefloating,
    bind = $mainMod, R, exec, wofi --show drun
    bind = $mainMod, X, togglesplit, # dwindle
    bind = $mainMod, F, fullscreen
    bind = $mainMod, S, fakefullscreen
    bind = $mainMod, SPACE, centerwindow
    bind = $mainMod, O, exec, systemctl suspend

    # Move focus with mainMod + arrow keys
    bind = $mainMod, left, movefocus, l
    bind = $mainMod, right, movefocus, r
    bind = $mainMod, up, movefocus, u
    bind = $mainMod, down, movefocus, d

    # Switch workspaces with mainMod + [0-9]
    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
    bind = $mainMod, 4, workspace, 4
    bind = $mainMod, 5, workspace, 5
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod, 0, workspace, 10

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10

    bind = $mainMod CTRL, 1, movetoworkspacesilent, 1
    bind = $mainMod CTRL, 2, movetoworkspacesilent, 2
    bind = $mainMod CTRL, 3, movetoworkspacesilent, 3
    bind = $mainMod CTRL, 4, movetoworkspacesilent, 4
    bind = $mainMod CTRL, 5, movetoworkspacesilent, 5
    bind = $mainMod CTRL, 6, movetoworkspacesilent, 6
    bind = $mainMod CTRL, 7, movetoworkspacesilent, 7
    bind = $mainMod CTRL, 8, movetoworkspacesilent, 8
    bind = $mainMod CTRL, 9, movetoworkspacesilent, 9
    bind = $mainMod CTRL, 0, movetoworkspacesilent, 10

    # Scroll through existing workspaces with mainMod + scroll
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1
    bind = $mainMod, mouse_left, workspace, e+1
    bind = $mainMod, mouse_right, workspace, e-1

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow

    bindl = , XF86AudioMute, exec, amixer set Master toggle
    bindle = , XF86AudioLowerVolume, exec, amixer set Master 5%-
    bindle = , XF86AudioRaiseVolume, exec, amixer set Master 5%+

    bind = , XF86AudioMicMute, exec, amixer set Capture toggle
    bind = $mainMod, XF86AudioLowerVolume, exec, amixer set Capture 5%-
    bind = $mainMod, XF86AudioRaiseVolume, exec, amixer set Capture 5%+

    bind = $mainMod SHIFT, c, exec, ~/.config/hypr/swayidle.sh

    bindle = , XF86MonBrightnessUp, exec, light -T 1.2
    bindle = , XF86MonBrightnessDown, exec, light -T 0.8

    bindle = $mainMod, XF86MonBrightnessUp, exec, ddcutil --bus 15 setvcp 10 + 5
    bindle = $mainMod, XF86MonBrightnessDown, exec, ddcutil --bus 15 setvcp 10 - 5

    # trigger when the switch is turning on
    bindl=,switch:off:Lid Switch,exec,hyprctl keyword monitor "eDP-1, 3000x2000@60, 530x1440, 2"
    # bindl=,switch:off:Lid Switch,exec,hyprpaper
    # trigger when the switch is turning off
    bindl=,switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1, disable"
    # bindl=,switch:on:Lid Switch,exec,hyprpaper

    # will switch to a submap called resize
    bind=ALT,R,submap,resize

    # will start a submap called "resize"
    submap=resize

    # sets repeatable binds for resizing the active window
    binde=,right,resizeactive,10 0
    binde=,left,resizeactive,-10 0
    binde=,up,resizeactive,0 -10
    binde=,down,resizeactive,0 10

    # use reset to go back to the global submap
    bind=,escape,submap,reset 

    # will reset the submap, meaning end the current one and return to the global one
    submap=reset
  '';
}
