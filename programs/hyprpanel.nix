# *.nix
{ inputs, ... }:
{
  imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];
  
  programs.hyprpanel = {
    enable = true;
    # systemd.enable = true;
    hyprland.enable = true;
    overwrite.enable = true;
    theme = "one_dark_split";
    layout = {
      "bar.layouts" = {
        "1" = {
          left = [ "power" "battery" "hypridle" "cpu" "netstat" ];
          middle = [ "workspaces" ];
          right = [ "volume" "network" "bluetooth" "clock" "notifications" ];
        };
        "0" = {
          left = [ "dashboard" "workspaces" "windowtitle" ];
          middle = [ ];
          right = [ "media" "volume" "network" "bluetooth" "battery" "clock" "hypridle" "notifications" ];
        };
      };
    };

    settings = {
      bar.launcher.autoDetectIcon = true;
      bar.workspaces.show_icons = true;

      menus.clock = {
        time = {
          military = true;
          hideSeconds = true;
        };
        weather.unit = "metric";
      };

      menus.dashboard.directories.enabled = false;
      menus.dashboard.stats.enable_gpu = false;

      theme.bar.transparent = true;

      theme.font = {
        name = "CaskaydiaCove NF";
        size = "16px";
      };

      theme.osd.enable = false;
    };
  };
}
