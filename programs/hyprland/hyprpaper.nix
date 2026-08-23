{ variants, ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = true;
      splash = false;
      wallpaper =
        if (variants.hostName == "roblor-matebook") then
          [
            {
              monitor = "eDP-1";
              path = "~/Pictures/Wallpapers/light.png";
            }
            {
              monitor = "DP-1";
              path = "~/Pictures/Wallpapers/one-piece-landscape.jpg";
            }
            {
              monitor = "";
              path = "~/Pictures/Wallpapers/wolf-1.jpg";
            }
          ]
        else if (variants.hostName == "roblor-desktop") then
          [
            {
              monitor = "HDMI-A-1";
              path = "~/Pictures/Wallpapers/light.jpg";
            }
            {
              monitor = "sunshine";
              path = "~/Pictures/Wallpapers/squirrel-1.jpg";
            }
            {
              monitor = "";
              path = "~/Pictures/Wallpapers/wolf-1.jpg";
            }
          ]
        else
          [ ];
    };
  };
  # home.file.".config/hypr/hyprpaper.conf" = {
  #   text = if (variants.hostName == "roblor-matebook") then ''
  #     preload = ~/Pictures/Wallpapers/wolf-1.jpg
  #     preload = ~/Pictures/Wallpapers/light.png
  #     preload = ~/Pictures/Wallpapers/dark.png
  #     preload = ~/Pictures/Wallpapers/one-piece-landscape.jpg

  #     wallpaper {
  #       monitor = eDP-1
  #       path = ~/Pictures/Wallpapers/light.png
  #     }
  #     wallpaper {
  #       monitor = DP-1
  #       path = ~/Pictures/Wallpapers/one-piece-landscape.jpg
  #     }
  #     wallpaper {
  #       monitor =
  #       path = ~/Pictures/Wallpapers/wolf-1.jpg
  #     }

  #     # ipc = off
  #     splash = false
  #   '' else if (variants.hostName == "roblor-desktop") then ''
  #     preload = ~/Pictures/Wallpapers/wolf-1.jpg
  #     preload = ~/Pictures/Wallpapers/light.jpg
  #     preload = ~/Pictures/Wallpapers/dark.jpg

  #     wallpaper = HDMI-A-1,~/Pictures/Wallpapers/light.jpg
  #     wallpaper = ,~/Pictures/Wallpapers/wolf-1.jpg
  #     wallpaper = sunshine,~/Pictures/Wallpapers/squirrel-1.jpg

  #     # ipc = off
  #     splash = false
  #   '' else "";
  #   executable = true;
  # };

  home.file."Pictures/Wallpapers" = {
    source = ../../images/Wallpapers;
    recursive = true;
  };
}
