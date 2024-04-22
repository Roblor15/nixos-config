{ config, pkgs, unstable, ... }:

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
  home.file.".config/alacritty/alacritty-light.toml".source = ./alacritty-light.toml;
  home.file.".config/alacritty/alacritty-dark.toml".source = ./alacritty-dark.toml;
  # home.file.".config/alacritty/light.toml".source = ./latte.toml;
  home.file.".config/alacritty/light.toml".source = pkgs.alacritty-theme.catppuccin_latte;
  home.file.".config/alacritty/dark.toml".source = pkgs.alacritty-theme.catppuccin_mocha;
}
