{ ... }:

{
  home.file.".config/hypr/change-theme.fish" = {
    text = ''
      #! /usr/bin/env fish

      argparse 't/theme=' -- $argv
      or return

      set gsett '[Settings]
      gtk-icon-theme-name = Adwaita
      gtk-theme-name = Adwaita'
      set gsett1 '
      gtk-application-prefer-dark-theme = true'

      if test $_flag_theme = "hyprland"
          # change alacritty color
          cp -f ~/.config/alacritty/bluish.toml ~/.config/alacritty/color.toml
          # kill hyprpaper
          pidof hyprpaper && pkill hyprpaper
          # change hyprland colors
          cp -f ~/.config/hypr/hyprland-colors.conf ~/.config/hypr/colors.conf
          # change eww colors
          cp -f ~/.config/eww/bar/hyprland-colors.scss ~/.config/eww/bar/colors.scss
          # change helix colors
          cp -f ~/.config/helix/themes/theme-blue.toml ~/.config/helix/themes/adaptive.toml
          # reload helix config
          pkill -USR1 hx || true
          # change theme for gtk
          string join0 $gsett $gsett1 > ~/.config/gtk-3.0/settings.ini
          string join0 $gsett $gsett1 > ~/.config/gtk-4.0/settings.ini
          # rm the theme dir
          rm -r /tmp/theme
      else if test $_flag_theme = "onepiece"
          cp -f ~/.config/hypr/onepiece-colors.conf ~/.config/hypr/colors.conf
          # change eww colors
          cp -f ~/.config/eww/bar/onepiece-colors.scss ~/.config/eww/bar/colors.scss
          # change hyprland colors
          if test -f /tmp/theme/light
              # change theme 
              rm /tmp/theme/light
              touch /tmp/theme/dark
              # change theme for gtk
              string join0 $gsett $gsett1 > ~/.config/gtk-3.0/settings.ini
              string join0 $gsett $gsett1 > ~/.config/gtk-4.0/settings.ini
              # run hyprpaper
              hyprctl hyprpaper wallpaper "eDP-1,~/Pictures/Wallpapers/dark.png"
              # change alacritty color
              cp -f ~/.config/alacritty/dark.toml ~/.config/alacritty/color.toml
              # change helix colors
              cp -f ~/.config/helix/themes/theme-dark.toml ~/.config/helix/themes/adaptive.toml
              # reload helix config
              pkill -USR1 hx || true
          else if test -f /tmp/theme/dark
              # change theme 
              rm /tmp/theme/dark
              touch /tmp/theme/light
              # change theme for gtk
              echo $gsett > ~/.config/gtk-3.0/settings.ini
              echo $gsett > ~/.config/gtk-4.0/settings.ini
              # run hyprpaper
              hyprctl hyprpaper wallpaper "eDP-1,~/Pictures/Wallpapers/light.png"
              # change alacritty color
              cp -f ~/.config/alacritty/light.toml ~/.config/alacritty/color.toml
              # change helix colors
              cp -f ~/.config/helix/themes/theme-light.toml ~/.config/helix/themes/adaptive.toml
              # reload helix config
              pkill -USR1 hx || true
          else
              # default theme light
              # systemctl --user start hyprpaper.service
              # change theme for gtk
              echo $gsett > ~/.config/gtk-3.0/settings.ini
              echo $gsett > ~/.config/gtk-4.0/settings.ini

              hyprpaper &
              # change theme 
              mkdir /tmp/theme
              touch /tmp/theme/light
              # close eww (problems with layers)
              eww --config ~/.config/eww/bar close bar
              # run hyprpaper
              hyprctl hyprpaper wallpaper "eDP-1,~/Pictures/Wallpapers/light.png"
              # change alacritty color
              cp -f ~/.config/alacritty/light.toml ~/.config/alacritty/color.toml
              # change helix colors
              cp -f ~/.config/helix/themes/theme-light.toml ~/.config/helix/themes/adaptive.toml
              # reload helix config
              pkill -USR1 hx || true
              sleep 5
              # open eww
              eww --config ~/.config/eww/bar open bar
          end
      end
    '';
    executable = true;
  };
}
