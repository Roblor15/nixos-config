{ variants, ... }:

{
  # services.hyprpaper = {
  #   enable = true;
  #   ipc = true;
  #   splash = false;
  #   preloads = [
  #     "~/Pictures/Wallpapers/wolf-1.jpg"
  #     "~/Pictures/Wallpapers/light.png"
  #     "~/Pictures/Wallpapers/dark.png"
  #     "~/Pictures/Wallpapers/one-piece-landscape.jpg"
  #   ];
  #   wallpapers = [
  #     "eDP-1,~/Pictures/Wallpapers/light.png"
  #     "DP-1,~/Pictures/Wallpapers/one-piece-landscape.jpg"
  #     ",~/Pictures/Wallpapers/wolf-1.jpg"
  #   ];
  # };
  home.file.".config/hypr/hyprpaper.conf" = {
    text = if (variants.hostName == "roblor-matebook") then ''
      preload = ~/Pictures/Wallpapers/wolf-1.jpg
      preload = ~/Pictures/Wallpapers/light.png
      preload = ~/Pictures/Wallpapers/dark.png
      preload = ~/Pictures/Wallpapers/one-piece-landscape.jpg

      wallpaper = eDP-1,~/Pictures/Wallpapers/light.png
      wallpaper = DP-1,~/Pictures/Wallpapers/one-piece-landscape.jpg
      wallpaper = ,~/Pictures/Wallpapers/wolf-1.jpg

      # ipc = off
      splash = false
    '' else if (variants.hostName == "roblor-desktop") then ''
      preload = ~/Pictures/Wallpapers/wolf-1.jpg
      preload = ~/Pictures/Wallpapers/light.jpg
      preload = ~/Pictures/Wallpapers/dark.png

      wallpaper = HDMI-A-1,~/Pictures/Wallpapers/light.jpg
      wallpaper = ,~/Pictures/Wallpapers/wolf-1.jpg

      # ipc = off
      splash = false
    '' else "";
    executable = true;
  };

  home.file."Pictures/Wallpapers" = {
    source = ../../images/Wallpapers;
    recursive = true;
  };
}
