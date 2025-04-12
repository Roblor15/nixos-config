{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      nix-your-shell fish | source
      tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time='24-hour format' --rainbow_prompt_separators=Slanted --powerline_prompt_heads=Round --powerline_prompt_tails=Slanted --powerline_prompt_style='Two lines, frame' --prompt_connection=Solid --powerline_right_prompt_frame=Yes --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons='Few icons' --transient=No
    '';
    shellInit = ''
      zoxide init fish | source
    '';
    plugins = [
      {
        name = "tide";
        src = pkgs.fetchFromGitHub {
          owner = "IlanCosman";
          repo = "tide";
          rev = "v6.0.1";
          sha256 = "sha256:oLD7gYFCIeIzBeAW1j62z5FnzWAp3xSfxxe7kBtTLgA=";
        };
      }
    ];
	};
}
