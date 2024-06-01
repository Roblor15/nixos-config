{ ... }:

{
  home.file.".config/hypr/position.fish" = {
    text = ''
      #! /usr/bin/env nix-shell
      #! nix-shell -i fish --packages jq

      if [ "$argv[2]" != "--no-int" ]
          set res (curl -s ipinfo.io | jq '.loc') 
          if [ "$res"  != "" ]
              echo $res > ~/.config/hypr/position
          else
              if test -e ~/.config/hypr/position
                  set res (cat ~/.config/hypr/position)
              else
                  return 1
              end
          end
      else
          if test -e ~/.config/hypr/position
              set res (cat ~/.config/hypr/position)
          else
              return 1
          end
      end

      set b (string split , $res)

      switch $argv[1]
          case --lat
              set b $b[1]
              echo $(string sub -s 2 $b)
          case --lon
              set b $b[2]
              echo $(string sub -l 7 $b)
      end
    '';
    executable = true;
  };
}
