{ ... }:

{
  home.file.".config/hypr/hypridle.fish" = {
    text = ''
      #! /usr/bin/env fish

      echo "change" > /tmp/eww/hypridle

      if pidof hypridle
          pkill hypridle
      else
          hypridle
      end
    '';
    executable = true;
  };

  home.file.".config/hypr/hypridle.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || hyprlock       # avoid starting multiple hyprlock instances.
        before_sleep_cmd = loginctl lock-session    # lock before suspend.
        after_sleep_cmd = hyprctl dispatch dpms on  # to avoid having to press a key twice to turn on the display.
    }

    listener {
        timeout = 150                                # 2.5min.
        on-timeout = light -O && light -S 5          # set monitor backlight to minimum, avoid 0 on OLED monitor.
        on-resume = light -I                 # monitor backlight restore.
    }

    listener {
        timeout = 300                                 # 5min
        on-timeout = loginctl lock-session            # lock screen when timeout has passed
    }

    listener {
        timeout = 310                                 # 5.5min
        on-timeout = hyprctl dispatch dpms off        # screen off when timeout has passed
        on-resume = hyprctl dispatch dpms on          # screen on when activity is detected after timeout has fired.
    }

    listener {
        timeout = 400                                 # 30min
        on-timeout = systemctl suspend                # suspend pc
    }
  '';
}
