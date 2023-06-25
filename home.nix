{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "roblor";
  home.homeDirectory = "/home/roblor";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    tiramisu
  ];

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Amber";
      size = 24;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH=$PATH:~/.cargo/bin

      eval "$(starship init bash)"
      eval "$(rustic completions bash 2> /dev/null)" 

      alias backup-data="borg create --stats --progress --compression auto,lzma,9 --patterns-from ~/borg-dati-patterns.lst /run/media/roblor/Roblor\'s\ Files/borg-backup::Dati-{now:%Y-%m-%dT%H:%M:%S}"
      alias backup-home="borg create --stats --progress --compression auto,lzma,9 --patterns-from ~/borg-home-patterns.lst /run/media/roblor/Roblor\'s\ Files/borg-backup::Home-{now:%Y-%m-%dT%H:%M:%S}"
      alias esp-idf="nix develop github:mirrexagon/nixpkgs-esp-dev#esp32-idf"
      alias clean-generations="sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2"
    '';
  };

  # fare con git

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

          };
        }
      ];
    };
    settings = {
      theme = "onelight";
      editor.statusline = {
        left = [ "mode" "spinner" "file-name" "separator" "version-control" ];
      };
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
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

  programs.alacritty = {
    enable = true;
    settings = {
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
    };
  };
}
