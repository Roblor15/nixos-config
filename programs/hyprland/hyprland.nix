{ pkgs, inputs, ... }:

{
  imports = [
    ./change-theme.nix  
    ./hypridle.nix
    ./hyprlock.nix
    ./position.nix
    ./colors.nix
    ./hyprpaper.nix
    ./rounded-borders.nix
    ./toggle_bars.nix
  ];

  wayland.windowManager.hyprland.enable = true;
  # wayland.windowManager.hyprland.package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  wayland.windowManager.hyprland.extraConfig = ''
    source = ~/.config/hypr/colors.conf
    # source = ~/.config/hypr/borders.conf

    # monitor=eDP-1,3000x2000@60,530x1440,2
    monitor=eDP-1,3000x2000@60,0x1440,2
    monitor=desc:Microstep MSI MP271Q PA3T090C00618,highres,0x0,1
    monitor=desc:Samsung Electric Company SAMSUNG 0x01000E00,3840x2160@60,auto,2.5
    monitor=,preferred,auto,1

    exec-once = ~/.config/hypr/change-theme.fish --theme onepiece
    exec-once = ~/.config/hypr/rounded-borders.fish
    exec-once = eww --config ~/.config/eww/bar open bar
    # exec-once = hyprpanel
    exec-once = hyprctl setcursor Bibata-Modern-Amber 24
    exec-once = hypridle
    exec-once = mako
    exec-once = wlsunset -l $(~/.config/hypr/position.fish --lat --no-int) -L $(~/.config/hypr/position.fish --lon --no-int) -t 3000
    exec-once = wl-paste --type text --watch cliphist store
    exec-once = wl-paste --type image --watch cliphist store
    exec-once = wluma

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

    device {
        name = magic-mouse-2
        sensitivity = -1
        natural_scroll = yes
    }

    device {
        name = virtual-mouse
        sensitivity = -1
        natural_scroll = yes
    }

    device {
        name = keychron-k3
        kb_layout = us
    }

    device {
        name = keychron-keychron-k3-2
        kb_layout = us
    }
    
    device {
        name = keychron-keychron-k3
        kb_layout = us
    }

    general {
        gaps_in = 5
        gaps_out = 20
        border_size = 2
        col.active_border = $active_border_1 $active_border_2 45deg
        col.inactive_border = $inactive_border

        layout = dwindle
    }

    decoration {
        rounding = 10

        shadow {
            enabled = yes
            range = 4
            render_power = 3
            color = $shadow
        }

        blur {
            enabled = true
            passes = 3
            size = 15
        }
    }

    animations {
        enabled = yes

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
        new_status=master
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
    # windowrulev2 = noblur,title:^(alacritty)$
    windowrulev2 = noblur,class:^(?:(?!Alacritty).)+$

    # See https://wiki.hyprland.org/Configuring/Keywords/ for more
    $mainMod = SUPER

    # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
    # bind = $mainMod, T, exec, alacritty
    bind = $mainMod, T, exec, wezterm
    bind = $mainMod, N, exec, alacritty -e nvim
    bind = $mainMod, B, exec, zen
    bind = $mainMod, C, killactive,
    bind = $mainMod, M, exit,
    bind = $mainMod, V, togglefloating,
    bind = $mainMod, R, exec, anyrun
    bind = $mainMod SHIFT, R, exec, cliphist list | anyrun --plugins ~/.config/anyrun/libstdin.so | cliphist decode | wl-copy
    bind = $mainMod, X, togglesplit, # dwindle
    bind = $mainMod, F, fullscreen
    bind = $mainMod, S, fullscreenstate
    bind = $mainMod, SPACE, centerwindow
    bindl = $mainMod, O, exec, systemctl suspend-then-hibernate
    bind = $mainMod, L, exec, hyprlock
    bind = $mainMod, W, exec, pkill wlsunset; wlsunset -l $(~/.config/hypr/position.fish --lat) -L $(~/.config/hypr/position.fish --lon) -t 3000
    bind = $mainMod SHIFT, W, exec, pkill wlsunset

    bind = $mainMod, P, exec, eww open --config ~/.config/eww/bar bar  
    bind = $mainMod SHIFT, P, exec, eww close --config ~/.config/eww/bar bar  
    bind = $mainMod ALT, 0, exec, eww open --config ~/.config/eww/bar bar --screen 0  
    bind = $mainMod ALT, 1, exec, eww open --config ~/.config/eww/bar bar --screen 1  
    # bind = $mainMod, P, exec, ~/.config/hypr/toggle_bars.fish  

    bind = $mainMod SHIFT, c, exec, ~/.config/hypr/hypridle.fish
    bind = $mainMod, h, exec, ~/.config/hypr/change-theme.fish --theme hyprland
    bind = $mainMod SHIFT, h, exec, ~/.config/hypr/change-theme.fish --theme onepiece

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

    bindle = $mainMod, Return, exec, hyprctl keyword monitor eDP-1,disable
    bindle = $mainMod SHIFT, Return, exec, hyprctl keyword monitor eDP-1,3000x2000@60,0x1440,2

    # Scroll through existing workspaces with mainMod + scroll
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1
    bind = $mainMod, mouse_left, workspace, e+1
    bind = $mainMod, mouse_right, workspace, e-1

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow

    bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle 
    bindle = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    bindle = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+

    bind = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    bind = $mainMod, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-
    bind = $mainMod, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+

    bindle = , XF86MonBrightnessUp, exec, light -T 1.2
    bindle = , XF86MonBrightnessDown, exec, light -T 0.8
    bindle = $mainMod, XF86MonBrightnessUp, exec, ddcutil --bus 15 setvcp 10 + 5
    bindle = $mainMod, XF86MonBrightnessDown, exec, ddcutil --bus 15 setvcp 10 - 5

    bind = , XF86Tools, exec, zen --new-window www.gmail.com
    bind = $mainMod, F10, exec, zen --new-window 'ext+container:name=UniTN&url=www.gmail.com'
    bind = $mainMod SHIFT, F10, exec, zen --new-window www.outlook.it 
    bind = $mainMod CTRL, F10, exec, zen --new-window 'ext+container:name=Tuni&url=www.outlook.it' 

    bind = , Print, exec,  grimblast --notify copysave output ~/Pictures/Screenshots/$(date +'%F-%T.png')
    bind = $mainMod, Print, exec,  grimblast --notify copysave active ~/Pictures/Screenshots/$(date +'%F-%T.png')
    bind = $mainMod SHIFT, Print, exec,  grimblast --notify copysave area ~/Pictures/Screenshots/$(date +'%F-%T.png')

    bind = CTRL, Print, exec,  grimblast --notify copy output
    bind = $mainMod CTRL, Print, exec,  grimblast --notify copy active
    bind = $mainMod CTRL SHIFT, Print, exec,  grimblast --notify copy area

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

    misc {
        disable_splash_rendering = true
        force_default_wallpaper = 2
    }

    cursor {
        inactive_timeout = 10
        hide_on_touch = true
        hotspot_padding = 0
    }

    workspace=1,monitor:eDP-1,default:true
    workspace=2,monitor:DP-1,default:true
  '';
}
