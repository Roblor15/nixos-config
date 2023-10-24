{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERN = "alacritty";
      };
      # window = {
      #   padding = {
      #     x = 20;
      #     y = 20;
      #   };
      #   dynamic_padding = true;
      # };
      font = {
        normal = {
          family = "CaskaydiaCove Nerd Font";
          style = "Book";
        };
        bold = {
          family = "CaskaydiaCove Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "CaskaydiaCove Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "CaskaydiaCove Nerd Font";
          style = "Bold Italic";
        };
        size = 11;
        # offset = {
        #   y = 1;
        # };
      };
      colors = {
        primary = {
          background = "0x24283b";
          foreground = "0xa9b1d6";
        };
        normal = {
          black = "0x32344a";
          red = "0xf7768e";
          green = "0x9ece6a";
          yellow = "0xe0af68";
          blue = "0x7aa2f7";
          magenta = "0xad8ee6";
          cyan = "0x449dab";
          white = "0x9699a8";
        };
        bright = {
          black = "0x444b6a";
          red = "0xff7a93";
          green = "0xb9f27c";
          yellow = "0xff9e64";
          blue = "0x7da6ff";
          magenta = "0xbb9af7";
          cyan = "0x0db9d7";
          white = "0xacb0d0";
        };
      };
      cursor = {
        style.shape = "Underline";
        vi_mode_style = "Block";
        unfocused_hollow = true;
      };
      mouse = {
        hide_when_typing = true;
      };
    };
  };
}
