{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.anyrun.homeManagerModules.default
  ];

  programs.anyrun = {
    enable = true;
    config = {
      plugins = [
        # An array of all the plugins you want, which either can be paths to the .so files, or their packages
        inputs.anyrun.packages.${pkgs.system}.applications
        inputs.anyrun.packages.${pkgs.system}.translate
        inputs.anyrun.packages.${pkgs.system}.websearch
        # ./some_plugin.so
        # "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/kidex"
      ];
      x = { fraction = 0.5; };
      y = { fraction = 0.3; };
      width = { fraction = 0.4; };
      height = { absolute = 5; };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = true;
      closeOnClick = false;
      showResultsImmediately = true;
      maxEntries = null;
    };
    extraCss = ''
      * {
        all: unset;
        font-size: 1rem;
      }

      #window,
      #match,
      #entry,
      #plugin,
      #main { 
        background: transparent; 
      }

      #match.activatable {
        border-radius: 7px;
        padding: 3px 3px;
        margin-top: 1px;
      }
      #match.activatable:first-child { margin-top: 9px; }
      #match.activatable:last-child { margin-bottom: 1px; }

      #plugin:hover #match.activatable {
        border-radius: 7px;
        padding: .3rem;
        margin-top: .01rem;
        margin-bottom: 0;
      }


      #match:selected {
        color: @theme_selected_fg_color;
        background: #FCA035;
        border-radius: 7px;
      }

      #entry {
        border-radius: 7px;
        margin: 3px;
        padding: 5px 5px;
        caret-color: white;
        font-size: 20px;
        font-weight: 700;
      }

      list > #plugin {
        border-top: 1px solid rgba(255,255,255,0.3);
        margin: 3px;
        padding-top: 3px;
        padding-left: 3px;
        font-weight: 400;
      }

      list > #plugin:first-child { 
        margin-top: .3rem;
      }

      list > #plugin:last-child { 
        margin-bottom: .3rem; 
      }

      list > #plugin:hover { 
        padding: 5px; 
      }

      box#main {
        border-color: #FCA035;    
        color: white;
        border-width: 4px;
        border-style: solid;
        margin-top: 15px;
        background-color: rgba(0,0,0,0.7);
        border-radius: 7px;
        padding: 5px;
      }

      zlabel#plugin {
        font-size:20px;
      }
    '';

    extraConfigFiles."applications.ron".text = ''
      Config(
        desktop_actions: true,
        max_entries: 5,
        terminal: Some("alacritty"),
      )
    '';

    extraConfigFiles."websearch.ron".text = ''
      Config(
        prefix: "?",
        engines: [Ecosia],
      )
    '';

    extraConfigFiles."translate.ron".text = ''
      Config(
        prefix: ":",
        language_delimiter: ">",
        max_entries: 3,
      )
    '';
  };
}
