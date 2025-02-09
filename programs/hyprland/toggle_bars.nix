{ ... }:

{
  home.file.".config/hypr/toggle_bars.fish" = {
    text = ''
        #! /usr/bin/env fish

        for i in (hyprpanel listWindows)
            if string match "bar*" $i
                hyprpanel toggleWindow $i
            end
        end
    '';
    executable = true;
  };
}
