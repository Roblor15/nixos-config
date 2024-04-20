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
      ];
    };
    settings = {
      theme = "onelight";
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
}
