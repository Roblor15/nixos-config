{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myNas.services.ollama;
  unstablePkgs = import inputs.unstable {
    system = pkgs.system;
  };
in
{
  options.myNas.services.ollama = {
    enable = lib.mkEnableOption "Abilita ollama server";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Dominio per accedere a ollama";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      package = unstablePkgs.ollama;
      enable = true;

      # L'Intel N150 non ha GPU Nvidia/AMD.
      # Forziamo su "false" per evitare che NixOS compili driver inutili e pesanti.
      acceleration = false;

      # Siccome n8n e Gitea girano sullo stesso NAS, comunicheranno in localhost.
      # Aprilo (true) solo se vuoi usare le API di Ollama direttamente dal tuo PC portatile.
      openFirewall = false;

      environmentVariables = {
        # SALVAVITA PER IL N150: Elabora una sola richiesta alla volta.
        # Se n8n, Gitea e tua cugina fanno richieste insieme, le mette in coda.
        OLLAMA_NUM_PARALLEL = "2";

        # Libera i 3GB di RAM di ZFS spegnendo il modello dopo 15 min di inattività
        OLLAMA_KEEP_ALIVE = "15m";
      };

      # LA MAGIA DI NIXOS: Scarica il modello automaticamente all'avvio del servizio!
      # Non dovrai scrivere "ollama run qwen..." a mano nel terminale.
      loadModels = [
        "granite4:3b-h"
        "gemma3:4b"
        # "qwen3.5:4b"
      ];
    };

    # services.caddy.virtualHosts."*.${cfg.domain}".extraConfig = ''
    #   # Definisci il matcher solo per "auth"
    #   @ollama host ollama.${cfg.domain}

    #   # Gestisci la richiesta
    #   handle @ollama {
    #     reverse_proxy 127.0.0.1:11434
    #   }
    # '';
  };
}
