{ ... }:

{
  home.file.".config/hypr/rounded-borders.fish" = {
    text = ''
        #! /usr/bin/env fish

        function change_borders --on-event change_bar_event
            set layers $(hyprctl layers -j)
            set monitors_with_bar (echo $layers | jq 'to_entries[] | select(.value.levels | .[] | .[] | .namespace=="gtk-layer-shell") | .key')

            if set -q monitors_with_bar[1]
                set com (string join ' and .key!=' $monitors_with_bar)
                set com (string join "" '.key!=' $com)

                set monitors_without_bar (echo $layers | jq -r "to_entries[] | select($com) | .key")
            else
                set monitors_without_bar (echo $layers | jq -r "to_entries[] | .key")
            end

            for monitor in $monitors_without_bar
                set monitor (string join "" 'm[' $monitor)
                set monitor (string join "" $monitor ']')

                # echo "workspace=1,monitor:eDP-1,default:true
        # workspace=2,monitor:DP-1,default:true
        # workspace=$monitor w[1],gapsin:0,gapsout:0,rounding:false,border:false
        # workspace=$monitor,gapsin:0,gapsout:0,rounding:false" >> ~/.config/hypr/borders.conf
                hyprctl keyword workspace $monitor,gapsin:0,gapsout:0,rounding:false
                hyprctl keyword workspace $monitor w[1],gapsin:0,gapsout:0,rounding:false,border:false
            end

            for monitor in $monitors_with_bar
                set monitor (string sub -s 2 -l (math (string length $monitor) - 2) $monitor)
                set monitor (string join "" 'm[' $monitor)
                set monitor (string join "" $monitor ']')

                hyprctl keyword workspace $monitor w[1],gapsin:5,gapsout:20,rounding:true,border:true
                hyprctl keyword workspace $monitor,gapsin:5,gapsout:20,rounding:true,border:true
            end
        end

        socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock |
            while read -l line
                if test $line = "openlayer>>gtk-layer-shell";
                    or string match -q -r "monitoradded*|monitorremoved*" $line
                    emit change_bar_event
                else if test $line = "closelayer>>gtk-layer-shell"
                    sleep 1
                    emit change_bar_event
                end
            end
    '';
    executable = true;
  };
}
