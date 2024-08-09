{ config, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    languages = {
      language = [
        {
          name = "rust";
          auto-pairs = {
            "(" = ")";
            "{" = "}";
            "[" = "]";
            "\"" = "\"";
            "`" = "`";
            "<" = ">";
            "'" = "'";
          };
        }
        {
          name = "java";
          auto-format = true;
          indent = { tab-width = 4; unit = "    "; };
        }
        {
          name = "typst";
          formatter = { command = "typstyle"; };
          auto-format = true;
          auto-pairs = {
            "(" = ")";
            "{" = "}";
            "[" = "]";
            "\"" = "\"";
            # "`" = "`";
            "<" = ">";
            "'" = "'";
            "*" = "*";
            "_" = "_";
            "$" = "$";
          };
        }
      ];
    };
    settings = {
      theme = "adaptive";
      editor = {
        auto-format = true;
        preview-completion-insert = false;
        completion-replace = true;
      };
      editor.statusline = {
        left = [ "mode" "spinner" "file-name" "separator" "version-control" ];
      };
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
      editor.whitespace = {
        render = {
          tab = "all";
          space = "none";
          newline = "none";
          nbsp = "none";
        };
        characters = {
          space = "·";
          nbsp = "⍽";
          tab = "→";
          newline = "⏎";
          tabpad = " ";
        };
      };
      editor.lsp = {
        display-inlay-hints = true;
      };
      editor.soft-wrap = {
        enable = true;
      };
    };
    defaultEditor = true;
  };

  home.file.".config/helix/themes/theme-light.toml".text = ''
    inherits = "onelight"
  '';
  home.file.".config/helix/themes/theme-dark.toml".text = ''
    inherits = "merionette"
  '';
  home.file.".config/helix/themes/theme-blue.toml".text = ''
    inherits = "tokyonight_storm"
  '';
}
