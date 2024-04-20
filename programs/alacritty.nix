{ config, unstable, ... }:

{
  programs.alacritty = {
    enable = true;
    package = unstable.alacritty;
    # settings = {
    #   import = [
    #     "~/.config/alacritty/latte.yml"
    #   ];
    #   env = {
    #     TERN = "alacritty";
    #   };
    #   # window = {
    #   #   padding = {
    #   #     x = 20;
    #   #     y = 20;
    #   #   };
    #   #   dynamic_padding = true;
    #   # };
    #   font = {
    #     normal = {
    #       family = "CaskaydiaCove Nerd Font";
    #       style = "Book";
    #     };
    #     bold = {
    #       family = "CaskaydiaCove Nerd Font";
    #       style = "Bold";
    #     };
    #     italic = {
    #       family = "CaskaydiaCove Nerd Font";
    #       style = "Italic";
    #     };
    #     bold_italic = {
    #       family = "CaskaydiaCove Nerd Font";
    #       style = "Bold Italic";
    #     };
    #     size = 11;
    #     # offset = {
    #     #   y = 1;
    #     # };
    #   };
    #   cursor = {
    #     style.shape = "Underline";
    #     vi_mode_style = "Block";
    #     unfocused_hollow = true;
    #   };
    #   mouse = {
    #     hide_when_typing = true;
    #   };
    # };
  };
  home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  home.file.".config/alacritty/latte.toml".source = ./latte.toml;
}
