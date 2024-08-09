{ ... }:

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
    text = ''
      preload = ~/Pictures/Wallpapers/wolf-1.jpg
      # preload = ~/Pictures/Wallpapers/wolf-2.jpg
      # preload = ~/Pictures/Wallpapers/wolf-3.jpg
      # preload = ~/Pictures/Wallpapers/210888.jpg
      # preload = ~/Pictures/Wallpapers/210902.jpg
      # preload = ~/Pictures/Wallpapers/one-piece-gear-5.png
      preload = ~/Pictures/Wallpapers/light.png
      preload = ~/Pictures/Wallpapers/dark.png
      # preload = ~/Pictures/Wallpapers/one-piece-landscape.jpg
      preload = ~/Pictures/Wallpapers/one-piece-ace.jpg

      # wallpaper = eDP-1,~/Pictures/Wallpapers/wolf-3.jpg
      # wallpaper = eDP-1,~/Pictures/Wallpapers/210902.jpg
      # wallpaper =  DP-1,~/Pictures/Wallpapers/wolf-2.jpg
      wallpaper = eDP-1,~/Pictures/Wallpapers/light.png
      # wallpaper = DP-1,~/Pictures/Wallpapers/one-piece-landscape.jpg
      wallpaper = DP-1,~/Pictures/Wallpapers/one-piece-ace.jpg
      wallpaper = ,~/Pictures/Wallpapers/wolf-1.jpg

      # ipc = off
      splash = false
    '';
    executable = true;
  };
}
