{ config, pkgs, /* unstable, */ ... }:

{
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = {
      general.import = [
        "~/.config/alacritty/color.toml"
      ];
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
          family = "Cascadia Mono NF";
          style = "Book";
        };
        bold = {
          family = "Cascadia Mono NF";
          style = "Bold";
        };
        italic = {
          family = "Cascadia Mono NF";
          style = "Italic";
        };
        bold_italic = {
          family = "Cascadia Mono NF";
          style = "Bold Italic";
        };
        size = 11;
        # offset = {
        #   y = 1;
        # };
      };
      cursor = {
        style = {
          shape = "Underline";
          blinking = "On";
        };
        vi_mode_style = {
          shape = "Block";
          blinking = "Off";
        };
        unfocused_hollow = true;
      };
      window.opacity = 0.8;
      mouse = {
        hide_when_typing = true;
      };
    };
  };
  home.file.".config/alacritty/light.toml".source = pkgs.alacritty-theme.catppuccin_latte;
  home.file.".config/alacritty/dark.toml".source = pkgs.alacritty-theme.catppuccin_mocha;
  home.file.".config/alacritty/bluish.toml".source = pkgs.alacritty-theme.bluish;
}
