{ ... }:

{
  programs.mangohud = {
    enable = true;
    enableSessionWide = false;

    settings = {
      # Queste impostazioni saranno applicate globalmente quando enableGlobal è true
      # Puoi renderle minime o includere tutte le info che ti servono per il test.
      # L'importante è il logging.
      # autostart_log = 1;
      # log_interval = 1000; # Ogni 1 secondo
      # output_folder = "/home/roblor/mangohud_logs"; # <--- CAMBIA 'tuoutente' con il tuo nome utente reale!
      # Assicurati che questa cartella esista o che MangoHud possa crearla.
      # Puoi anche usare un percorso relativo tipo "./mangohud_logs" che creerà una cartella
      # nella directory da cui avvii il gioco (se applicabile), ma un percorso assoluto è più sicuro.

      # Puoi anche mettere qui le opzioni base per l'overlay se vuoi vederlo:
      fps = true;
      gpu_temp = true;
      cpu_temp = true;
      position = "top-left";
    };

  };
}
