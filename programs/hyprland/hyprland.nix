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

  systemd.user.services.hyprland-headless-init = lib.mkIf (variants.hostName == "roblor-desktop") {
    Unit = {
      Description = "Inizializza monitor headless per Hyprland";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "PATH=/run/current-system/sw/bin:/etc/profiles/per-user/%u/bin:/bin";
      ExecStart = "${pkgs.bash}/bin/bash -c 'while [ ! -d \"%t/hypr\" ] || [ -z \"$(ls -A %t/hypr 2>/dev/null)\" ]; do sleep 1; done; sleep 2; export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 %t/hypr | head -n 1); hyprctl output create headless sunshine'";
    };
  };

  wayland.windowManager.hyprland =
    let
      eww-command =
        if (variants.hostName == "roblor-matebook") then
          "eww open --config /home/roblor/.config/eww/bar bar && eww update --config /home/roblor/.config/eww/bar desktop=false"
        else
          "eww open --config /home/roblor/.config/eww/bar bar";

      suspend-cmd =
        if (variants.hostName == "roblor-matebook") then
          "systemctl suspend-then-hibernate"
        else
          "systemctl suspend";

      desktop-exec =
        if (variants.hostName == "roblor-desktop") then
          ''
            hl.exec_cmd("systemctl --user restart sunshine")
            hl.exec_cmd("steam -silent")
          ''
        else
          "";
    in
    {
      enable = true;
      configType = "lua";

      # Non usiamo più extraConfig. Facciamo generare TUTTO a Home Manager in modo nativo.
      settings = {
        # --- MONITOR ---
        monitor = [
          {
            output = "eDP-1";
            mode = "3000x2000@60";
            position = "0x1440";
            scale = 2;
          }
          {
            output = "desc:Microstep MSI MP271Q PA3T090C00618";
            mode = "highres";
            position = "0x0";
            scale = 1;
          }
          {
            output = "desc:Samsung Electric Company SAMSUNG 0x01000E00";
            mode = "3840x2160@60";
            position = "1500x1440";
            scale = 1.5;
          }
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = 1;
          }
        ]
        ++ (
          if variants.hostName == "roblor-desktop" then
            [
              {
                output = "sunshine";
                mode = "2560x1440@60";
                position = "30000x0";
                scale = 1;
              }
            ]
          else
            [ ]
        );

        # --- WORKSPACES REGLES ---
        workspace_rule = [
          {
            workspace = "1";
            monitor = "eDP-1";
            default = true;
          }
          {
            workspace = "2";
            monitor = "DP-1";
            default = true;
          }
        ]
        ++ (
          if variants.hostName == "roblor-desktop" then
            [
              {
                workspace = "99";
                monitor = "sunshine";
                default = true;
              }
            ]
          else
            [ ]
        );

        # --- DISPOSITIVI ---
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
          {
            name = "keyboard-passthrough";
            kb_layout = "us";
          }
        ];

        # --- AUTOSTART (Exec Once tramite evento "on") ---
        on = {
          _args = [
            "hyprland.start"
            (lib.generators.mkLuaInline ''
              function()
                hl.exec_cmd("~/.config/hypr/change-theme.fish --theme onepiece")
                hl.exec_cmd("~/.config/hypr/rounded-borders.fish")
                hl.exec_cmd("${eww-command}")
                hl.exec_cmd("hyprctl setcursor Bibata-Modern-Amber 24")
                hl.exec_cmd("hypridle")
                hl.exec_cmd("mako")
                hl.exec_cmd("wlsunset -l $(~/.config/hypr/position.fish --lat --no-int) -L $(~/.config/hypr/position.fish --lon --no-int) -t 3000")
                hl.exec_cmd("wl-paste --type text --watch cliphist store")
                hl.exec_cmd("wl-paste --type image --watch cliphist store")
                hl.exec_cmd("wluma")
                ${desktop-exec}
              end
            '')
          ];
        };

        # --- GESTURES E ANIMAZIONI ---
        gesture = {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        };

        curve = [
          {
            _args = [
              "myBezier"
              {
                type = "bezier";
                points = [
                  [
                    0.05
                    0.9
                  ]
                  [
                    0.1
                    1.05
                  ]
                ];
              }
            ];
          }
        ];

        animation = [
          {
            leaf = "windows";
            enabled = true;
            speed = 7;
            bezier = "myBezier";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 7;
            bezier = "default";
            style = "popin 80%";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 10;
            bezier = "default";
          }
          {
            leaf = "borderangle";
            enabled = true;
            speed = 8;
            bezier = "default";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 7;
            bezier = "default";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 6;
            bezier = "default";
          }
        ];

        # --- BLOCCO CONFIG (Raggruppa le vecchie opzioni sparpagliate e previene il crash) ---
        config = {
          general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
            # Importa e legge dinamicamente i colori dal file Lua
            "col.active_border" = lib.generators.mkLuaInline ''
              { colors = { dofile(os.getenv("HOME") .. "/.config/hypr/colors.lua").active_border_1, dofile(os.getenv("HOME") .. "/.config/hypr/colors.lua").active_border_2 }, angle = 45 }
            '';
            "col.inactive_border" = lib.generators.mkLuaInline ''dofile(os.getenv("HOME") .. "/.config/hypr/colors.lua").inactive_border'';
            layout = "dwindle";
          };
          decoration = {
            rounding = 10;
            blur = { enabled = true; passes = 3; size = 15; };
            shadow = { 
              enabled = true; range = 4; render_power = 3; 
              color = lib.generators.mkLuaInline ''dofile(os.getenv("HOME") .. "/.config/hypr/colors.lua").shadow''; 
            };
          };
          input = {
            kb_layout = "it";
            follow_mouse = 1; # Nota: in lua usa 1 invece di true
            touchpad = {
              natural_scroll = true;
            };
            sensitivity = 0;
          };
          misc = {
            disable_splash_rendering = true;
            force_default_wallpaper = 2;
          };
          cursor = {
            hide_on_touch = true;
            hotspot_padding = 0;
            inactive_timeout = 10;
          };
          dwindle = {
            preserve_split = true;
          };
          master = {
            new_status = "master";
          };
          animations = {
            enabled = true;
          };
        };

        # --- BINDS ---
        bind = [
          # Programmi
          {
            _args = [
              "SUPER + T"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wezterm\")")
            ];
          }
          {
            _args = [
              "SUPER + N"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"alacritty -e nvim\")")
            ];
          }
          {
            _args = [
              "SUPER + B"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"firefox\")")
            ];
          }
          {
            _args = [
              "SUPER + C"
              (lib.generators.mkLuaInline "hl.dsp.window.close()")
            ];
          }
          {
            _args = [
              "SUPER + M"
              (lib.generators.mkLuaInline "hl.dsp.exit()")
            ];
          }
          {
            _args = [
              "SUPER + V"
              (lib.generators.mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })")
            ];
          }
          {
            _args = [
              "SUPER + R"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"fuzzel\")")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + R"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"cliphist list | fuzzel --dmenu | cliphist decode | wl-copy\")")
            ];
          }
          {
            _args = [
              "SUPER + X"
              (lib.generators.mkLuaInline "hl.dsp.layout(\"togglesplit\")")
            ];
          }
          {
            _args = [
              "SUPER + F"
              (lib.generators.mkLuaInline "hl.dsp.window.fullscreen()")
            ];
          }
          {
            _args = [
              "SUPER + SPACE"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprctl dispatch centerwindow\")")
            ];
          }
          {
            _args = [
              "SUPER + G"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"steam\")")
            ];
          }
          {
            _args = [
              "SUPER + O"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${suspend-cmd}\")")
            ];
          }
          {
            _args = [
              "SUPER + L"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprlock\")")
            ];
          }
          {
            _args = [
              "SUPER + W"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"pkill wlsunset; wlsunset -l $(~/.config/hypr/position.fish --lat) -L $(~/.config/hypr/position.fish --lon) -t 3000\")")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + W"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"pkill wlsunset\")")
            ];
          }
          {
            _args = [
              "SUPER + P"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${eww-command}\")")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + P"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"eww close --config ~/.config/eww/bar bar\")")
            ];
          }
          {
            _args = [
              "SUPER + ALT + 0"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${eww-command} --screen 0\")")
            ];
          }
          {
            _args = [
              "SUPER + ALT + 1"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${eww-command} --screen 1\")")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + C"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"~/.config/hypr/hypridle.fish\")")
            ];
          }
          {
            _args = [
              "SUPER + H"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"~/.config/hypr/change-theme.fish --theme hyprland\")")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + H"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"~/.config/hypr/change-theme.fish --theme onepiece\")")
            ];
          }
          {
            _args = [
              "SUPER + S"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprctl keyword 'monitor' 'desc:Samsung Electric Company SAMSUNG 0x01000E00,3840x2160@60,auto,1'\")")
            ];
          }
          {
            _args = [
              "SUPER + CTRL + R"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprctl reload\")")
            ];
          }

          # Movimento focus
          {
            _args = [
              "SUPER + left"
              (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"left\" })")
            ];
          }
          {
            _args = [
              "SUPER + right"
              (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"right\" })")
            ];
          }
          {
            _args = [
              "SUPER + up"
              (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"up\" })")
            ];
          }
          {
            _args = [
              "SUPER + down"
              (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"down\" })")
            ];
          }

          # Focus con il mouse
          {
            _args = [
              "SUPER + mouse_down"
              (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e+1\" })")
            ];
          }
          {
            _args = [
              "SUPER + mouse_up"
              (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e-1\" })")
            ];
          }
          {
            _args = [
              "SUPER + mouse_left"
              (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e+1\" })")
            ];
          }
          {
            _args = [
              "SUPER + mouse_right"
              (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e-1\" })")
            ];
          }

          # Media keys & Utilities (con repeating/locked properties ove serve)
          {
            _args = [
              "XF86AudioMicMute"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle\")")
            ];
          }
          {
            _args = [
              "SUPER + XF86AudioLowerVolume"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-\")")
            ];
          }
          {
            _args = [
              "SUPER + XF86AudioRaiseVolume"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+\")")
            ];
          }
          {
            _args = [
              "XF86Tools"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"firefox --new-window www.gmail.com\")")
            ];
          }
          {
            _args = [
              "SUPER + F10"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"firefox --new-window 'ext+container:name=UniTN&url=www.gmail.com'\")")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + F10"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"firefox --new-window www.outlook.it\")")
            ];
          }
          {
            _args = [
              "SUPER + CTRL + F10"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"firefox --new-window 'ext+container:name=Tuni&url=www.outlook.it'\")")
            ];
          }
          {
            _args = [
              "Print"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify copysave output ~/Pictures/Screenshots/$(date +'%F-%T.png')\")")
            ];
          }
          {
            _args = [
              "SUPER + Print"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify copysave active ~/Pictures/Screenshots/$(date +'%F-%T.png')\")")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + Print"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify copysave area ~/Pictures/Screenshots/$(date +'%F-%T.png')\")")
            ];
          }
          {
            _args = [
              "CTRL + Print"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify copy output\")")
            ];
          }
          {
            _args = [
              "SUPER + CTRL + Print"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify copy active\")")
            ];
          }
          {
            _args = [
              "SUPER + CTRL + SHIFT + Print"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify copy area\")")
            ];
          }

          # --- BLOCCO bindl ---
          {
            _args = [
              "XF86AudioMute"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")")
              { locked = true; }
            ];
          }
          {
            _args = [
              "switch:off:Lid Switch"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprctl keyword monitor 'eDP-1, 3000x2000@60, 530x1440, 2'\")")
              { locked = true; }
            ];
          }
          {
            _args = [
              "switch:on:Lid Switch"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprctl keyword monitor 'eDP-1, disable'\")")
              { locked = true; }
            ];
          }

          # --- BLOCCO bindle ---
          {
            _args = [
              "SUPER + Return"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprctl keyword monitor eDP-1,disable\")")
              {
                locked = true;
                repeating = true;
              }
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + Return"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprctl keyword monitor eDP-1,3000x2000@60,0x1440,2\")")
              {
                locked = true;
                repeating = true;
              }
            ];
          }
          {
            _args = [
              "XF86AudioLowerVolume"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")")
              {
                locked = true;
                repeating = true;
              }
            ];
          }
          {
            _args = [
              "XF86AudioRaiseVolume"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+\")")
              {
                locked = true;
                repeating = true;
              }
            ];
          }
          {
            _args = [
              "XF86MonBrightnessUp"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"light -T 1.2\")")
              {
                locked = true;
                repeating = true;
              }
            ];
          }
          {
            _args = [
              "XF86MonBrightnessDown"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"light -T 0.8\")")
              {
                locked = true;
                repeating = true;
              }
            ];
          }
          {
            _args = [
              "SUPER + XF86MonBrightnessUp"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"ddcutil --model \\\"MSI MP271Q\\\" setvcp 10 + 5\")")
              {
                locked = true;
                repeating = true;
              }
            ];
          }
          {
            _args = [
              "SUPER + XF86MonBrightnessDown"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"ddcutil --model \\\"MSI MP271Q\\\" setvcp 10 - 5\")")
              {
                locked = true;
                repeating = true;
              }
            ];
          }

          # --- BLOCCO bindm ---
          {
            _args = [
              "SUPER + mouse:272"
              (lib.generators.mkLuaInline "hl.dsp.window.drag()")
              { mouse = true; }
            ];
          }
          {
            _args = [
              "SUPER + mouse:273"
              (lib.generators.mkLuaInline "hl.dsp.window.resize()")
              { mouse = true; }
            ];
          }

          # TRIGGER PER LA SUBMAP
          {
            _args = [
              "ALT + R"
              (lib.generators.mkLuaInline "hl.dsp.submap(\"resize\")")
            ];
          }

        ]
        ++ (
          # Generazione dinamica dei tasti numerici per workspaces 1-10 per non scrivere 30 righe
          builtins.concatLists (
            builtins.genList (
              i:
              let
                ws = toString (if i == 9 then 10 else i + 1);
                key = if ws == "10" then "0" else ws;
              in
              [
                {
                  _args = [
                    "SUPER + ${key}"
                    (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = ${ws} })")
                  ];
                }
                {
                  _args = [
                    "SUPER + SHIFT + ${key}"
                    (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = ${ws} })")
                  ];
                }
                {
                  _args = [
                    "SUPER + CTRL + ${key}"
                    (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprctl dispatch movetoworkspacesilent ${ws}\")")
                  ];
                }
              ]
            ) 10
          )
        );

        # --- DEFINIZIONE SUBMAP PURA NATIVA LUA ---
        # Risolve definitivamente il blocco del tasto Esc e Frecce!
        define_submap = {
          _args = [
            "resize"
            (lib.generators.mkLuaInline ''
              function()
                hl.bind("right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
                hl.bind("left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
                hl.bind("up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
                hl.bind("down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
                hl.bind("escape", hl.dsp.submap("reset"))
              end
            '')
          ];
        };
      };
    };
}
