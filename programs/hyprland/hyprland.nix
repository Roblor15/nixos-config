{
  pkgs,
  inputs,
  lib,
  variants,
  ...
}:

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

  wayland.windowManager.hyprland =
    let
      eww-command =
        if (variants.hostName == "roblor-matebook") then
          "eww open --config /home/roblor/.config/eww/bar bar && eww update --config /home/roblor/.config/eww/bar desktop=false"
        else
          "eww open --config /home/roblor/.config/eww/bar bar";
    in
    {
      enable = true;
      # wayland.windowManager.hyprland.package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      settings = {
        source = "~/.config/hypr/colors.conf";
        monitor = [
          "eDP-1,3000x2000@60,0x1440,2"
          "desc:Microstep MSI MP271Q PA3T090C00618,highres,0x0,1"
          "desc:Samsung Electric Company SAMSUNG 0x01000E00,3840x2160@60,auto,1.5"
          ",preferred,auto,1"
        ];
        exec-once = [
          "~/.config/hypr/change-theme.fish --theme onepiece"
          "~/.config/hypr/rounded-borders.fish"
          eww-command
          "hyprctl setcursor Bibata-Modern-Amber 24"
          "hypridle"
          "mako"
          "wlsunset -l $(~/.config/hypr/position.fish --lat --no-int) -L $(~/.config/hypr/position.fish --lon --no-int) -t 3000"
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          "wluma"
        ]
        ++ (
          if variants.hostName == "roblor-desktop" then
            [
              "steam -silent"
            ]
          else
            [ ]
        );

        input = {
          kb_layout = "it";
          follow_mouse = true;
          touchpad.natural_scroll = true;
          sensitivity = 0;
        };

        device = [
          {
            name = "magic-mouse-2";
            sensitivity = -1;
            natural_scroll = true;
          }
          {
            name = "virtual-mouse";
            sensitivity = -1;
            natural_scroll = true;
          }
          {
            name = "keychron-k3";
            kb_layout = "us";
          }
          {
            name = "keychron-keychron-k3-2";
            kb_layout = "us";
          }
          {
            name = "keychron-keychron-k3";
            kb_layout = "us";
          }
        ];

        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          "col.active_border" = "$active_border_1 $active_border_2 45deg";
          "col.inactive_border" = "$inactive_border";
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "$shadow";
          };
          blur = {
            enabled = true;
            passes = 3;
            size = 15;
          };
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master.new_status = "master";
        gesture = [
          "3, horizontal, workspace"
          "2, pinch, mod: SUPER, resize"
        ];

        windowrulev2 = [ "noblur,class:^(?:(?!Alacritty).)+$" ];

        bind = [
          "SUPER, T, exec, wezterm"
          "SUPER, N, exec, alacritty -e nvim"
          "SUPER, B, exec, firefox"
          "SUPER, C, killactive,"
          "SUPER, M, exit,"
          "SUPER, V, togglefloating,"
          "SUPER, R, exec, fuzzel"
          "SUPER SHIFT, R, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"
          "SUPER, X, togglesplit,"
          "SUPER, F, fullscreen"
          "SUPER, SPACE, centerwindow"
          "SUPER, G, exec, steam"
          (
            if (variants.hostName == "roblor-matebook") then
              "SUPER, O, exec, systemctl suspend-then-hibernate"
            else
              "SUPER, O, exec, systemctl suspend"
          )
          "SUPER, L, exec, hyprlock"
          "SUPER, W, exec, pkill wlsunset; wlsunset -l $(~/.config/hypr/position.fish --lat) -L $(~/.config/hypr/position.fish --lon) -t 3000"
          "SUPER SHIFT, W, exec, pkill wlsunset"
          "SUPER, P, exec, ${eww-command}"
          "SUPER SHIFT, P, exec, eww close --config ~/.config/eww/bar bar"
          "SUPER ALT, 0, exec, ${eww-command} --screen 0"
          "SUPER ALT, 1, exec, ${eww-command} --screen 1"
          "SUPER SHIFT, c, exec, ~/.config/hypr/hypridle.fish"
          "SUPER, h, exec, ~/.config/hypr/change-theme.fish --theme hyprland"
          "SUPER SHIFT, h, exec, ~/.config/hypr/change-theme.fish --theme onepiece"
          "SUPER, S, exec, hyprctl keyword 'monitor' 'desc:Samsung Electric Company SAMSUNG 0x01000E00,3840x2160@60,auto,1'"
          "SUPER, S, exec, hyprctl keyword 'monitor' 'desc:Samsung Electric Company SAMSUNG 0x01000E00,3840x2160@60,auto,1'"
          "SUPER CTRL, R, exec, hyprctl reload"
          "SUPER, left, movefocus, l"
          "SUPER, right, movefocus, r"
          "SUPER, up, movefocus, u"
          "SUPER, down, movefocus, d"
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER, 6, workspace, 6"
          "SUPER, 7, workspace, 7"
          "SUPER, 8, workspace, 8"
          "SUPER, 9, workspace, 9"
          "SUPER, 0, workspace, 10"
          "SUPER SHIFT, 1, movetoworkspace, 1"
          "SUPER SHIFT, 2, movetoworkspace, 2"
          "SUPER SHIFT, 3, movetoworkspace, 3"
          "SUPER SHIFT, 4, movetoworkspace, 4"
          "SUPER SHIFT, 5, movetoworkspace, 5"
          "SUPER SHIFT, 6, movetoworkspace, 6"
          "SUPER SHIFT, 7, movetoworkspace, 7"
          "SUPER SHIFT, 8, movetoworkspace, 8"
          "SUPER SHIFT, 9, movetoworkspace, 9"
          "SUPER SHIFT, 0, movetoworkspace, 10"
          "SUPER CTRL, 1, movetoworkspacesilent, 1"
          "SUPER CTRL, 2, movetoworkspacesilent, 2"
          "SUPER CTRL, 3, movetoworkspacesilent, 3"
          "SUPER CTRL, 4, movetoworkspacesilent, 4"
          "SUPER CTRL, 5, movetoworkspacesilent, 5"
          "SUPER CTRL, 6, movetoworkspacesilent, 6"
          "SUPER CTRL, 7, movetoworkspacesilent, 7"
          "SUPER CTRL, 8, movetoworkspacesilent, 8"
          "SUPER CTRL, 9, movetoworkspacesilent, 9"
          "SUPER CTRL, 0, movetoworkspacesilent, 10"
          "SUPER, mouse_down, workspace, e+1"
          "SUPER, mouse_up, workspace, e-1"
          "SUPER, mouse_left, workspace, e+1"
          "SUPER, mouse_right, workspace, e-1"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          "SUPER, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-"
          "SUPER, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+"
          ", XF86Tools, exec, firefox --new-window www.gmail.com"
          "SUPER, F10, exec, firefox --new-window 'ext+container:name=UniTN&url=www.gmail.com'"
          "SUPER SHIFT, F10, exec, firefox --new-window www.outlook.it"
          "SUPER CTRL, F10, exec, firefox --new-window 'ext+container:name=Tuni&url=www.outlook.it'"
          ", Print, exec,  grimblast --notify copysave output ~/Pictures/Screenshots/$(date +'%F-%T.png')"
          "SUPER, Print, exec,  grimblast --notify copysave active ~/Pictures/Screenshots/$(date +'%F-%T.png')"
          "SUPER SHIFT, Print, exec,  grimblast --notify copysave area ~/Pictures/Screenshots/$(date +'%F-%T.png')"
          "CTRL, Print, exec,  grimblast --notify copy output"
          "SUPER CTRL, Print, exec,  grimblast --notify copy active"
          "SUPER CTRL SHIFT, Print, exec,  grimblast --notify copy area"
        ];

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];

        bindl = [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          # trigger when the switch is turning on
          ",switch:off:Lid Switch,exec,hyprctl keyword monitor 'eDP-1, 3000x2000@60, 530x1440, 2'"
          # bindl=,switch:off:Lid Switch,exec,hyprpaper
          # trigger when the switch is turning off
          ",switch:on:Lid Switch,exec,hyprctl keyword monitor 'eDP-1, disable'"
          # bindl=,switch:on:Lid Switch,exec,hyprpaper
        ];

        bindle = [
          "SUPER, Return, exec, hyprctl keyword monitor eDP-1,disable"
          "SUPER SHIFT, Return, exec, hyprctl keyword monitor eDP-1,3000x2000@60,0x1440,2"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86MonBrightnessUp, exec, light -T 1.2"
          ", XF86MonBrightnessDown, exec, light -T 0.8"
          "SUPER, XF86MonBrightnessUp, exec, ddcutil --model \"MSI MP271Q\" setvcp 10 + 5"
          "SUPER, XF86MonBrightnessDown, exec, ddcutil --model \"MSI MP271Q\" setvcp 10 - 5"
        ];

        misc = {
          disable_splash_rendering = true;
          force_default_wallpaper = 2;
        };

        cursor = {
          inactive_timeout = 10;
          hide_on_touch = true;
          hotspot_padding = 0;
        };

        workspace = lib.mkIf (variants.hostName == "roblor-matebook") [
          "1,monitor:eDP-1,default:true"
          "2,monitor:DP-1,default:true"
        ];
      };
      extraConfig = ''
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
    };
}
