{ ... }:

{
  home.file.".config/hypr/change-theme.fish" = {
    text = ''
      #! /usr/bin/env fish

      argparse 't/theme=' -- $argv
      or return

      if test $_flag_theme = "hyprland"
          cp -f ~/.config/alacritty/bluish.toml ~/.config/alacritty/color.toml
          pidof hyprpaper && pkill hyprpaper
          cp -f ~/.config/hypr/hyprland-colors.conf ~/.config/hypr/colors.conf
          cp -f ~/.config/eww/bar/hyprland-colors.scss ~/.config/eww/bar/colors.scss
          rm -r /tmp/theme
      else if test $_flag_theme = "onepiece"
          cp -f ~/.config/hypr/onepiece-colors.conf ~/.config/hypr/colors.conf
          cp -f ~/.config/eww/bar/onepiece-colors.scss ~/.config/eww/bar/colors.scss
          if test -f /tmp/theme/light
              rm /tmp/theme/light
              touch /tmp/theme/dark
              hyprctl hyprpaper wallpaper "eDP-1,~/Pictures/Wallpapers/dark.png"
              cp -f ~/.config/alacritty/dark.toml ~/.config/alacritty/color.toml
          else if test -f /tmp/theme/dark
              rm /tmp/theme/dark
              touch /tmp/theme/light
              hyprctl hyprpaper wallpaper "eDP-1,~/Pictures/Wallpapers/light.png"
              cp -f ~/.config/alacritty/light.toml ~/.config/alacritty/color.toml
          else
              # systemctl --user start hyprpaper.service
              hyprpaper &
              mkdir /tmp/theme
              touch /tmp/theme/light
              eww --config ~/.config/eww/bar close bar
              hyprctl hyprpaper wallpaper "eDP-1,~/Pictures/Wallpapers/light.png"
              cp -f ~/.config/alacritty/light.toml ~/.config/alacritty/color.toml
              sleep 5
              eww --config ~/.config/eww/bar open bar
          end
      end
    '';
    executable = true;
  };
}
