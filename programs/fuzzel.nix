{ pkgs, ... }:

{
  programs.fuzzel.enable = true;
  programs.fuzzel.settings = {
    main = {
      terminal = "wezterm -e {cmd}";
      layer = "overlay";
      font = "Iosevka Aile:size=16";
      horizontal-pad = 10;
      vertical-pad = 10;
      inner-pad = 4;
      width = 50;
      lines = 10;
    };
    border = {
      width = 4;
      radius = 5;
    };
    colors = {
      background = "35141DDD";
      text = "FFFFFFFF";
      selection = "FCA035FF";
      selection-text = "35141DFF";
      border = "FCA035FF";
    };
  };
}
