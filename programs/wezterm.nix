{ ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local color = require 'color'

      local config = {}

      config.enable_wayland = true
      config.window_background_opacity = 0.8

      config.font = wezterm.font {
        family = 'Iosevka Term',
        stretch = 'Expanded',
        weight = 'DemiBold'
      }
      config.font_size = 11.0

      config.hide_tab_bar_if_only_one_tab = true
      config.window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      }

      config.color_scheme = color.color_scheme
      config.default_cursor_style = 'SteadyUnderline'

      return config
    '';
  };

  home.file.".config/wezterm/light.lua".text = ''
    return {
      color_scheme = 'One Light (Gogh)'
    }
  '';
  home.file.".config/wezterm/dark.lua".text = ''
    return {
      color_scheme = 'Horizon Dark (Gogh)'
    }
  '';
}

