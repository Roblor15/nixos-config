{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings = {
    builders-use-substitutes = true;
    substituters = [
      "https://hyprland.cachix.org"
      "https://anyrun.cachix.org"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  boot.supportedFilesystems = [ "ntfs" ];

  hardware.i2c.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-bcdb7e4a-a24a-4781-a361-c9401db61474".device = "/dev/disk/by-uuid/bcdb7e4a-a24a-4781-a361-c9401db61474";
  boot.initrd.luks.devices."luks-bcdb7e4a-a24a-4781-a361-c9401db61474".keyFile = "/crypto_keyfile.bin";  

  networking.hostName = "roblor-matebook"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";
  # time.timeZone = "Europe/Helsinki";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "it2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    # pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.roblor = {
    isNormalUser = true;
    description = "Roberto";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "video"
      "i2c"
      # "tss"
      "adbusers"
      "plugdev"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1zKtf72PNwwrYhc5StUy2UQeWGwCBiGHRQK/gpTLCqNleloK87q33628BGVx+f9oU2YcvF5+rwLeRJZEUpo3cdkHK5vLV9fM4T7pPWQBAkvNm0U3tro+AiODCw3XQEn0lbjLsw3MjhR7oZCHFbFRzJ77xQKMdr6O+qyamULLOgpEzmdJxA60dWsMiShDKX/2k31fmpAweP48UDqfUfgXwnk+93gfaKh+4kGCmMOCHICLi9nTK53GocLgPeBB8Hq8V6fdxdH3QzCUMQ/FOiclcvXeDmIYaN8DFR1fIJeGCIl7zdLpvwEC9013Gmtgb3Pr3hzkFECG17+3LHydlhHx+5EDfx2C0IW8l9veJXOREw1Qt9FtAbLnCqbe+hcq0apOL+Qdgtu4Yfis8VSt0JjSr3WnGNLGi7D3+Q99VQ1cgZ4lP0oRQ+6A4fXWpRjq2PZPBEcRwqbqMjQdK5zciLkfvXPiJiV+QuaszyGA7pDgst0Ve81wVsfHd2sx8Vqzf4T8SzeUwlk3o/I/jZCPOYkshENl8+R4stDf96sHD9whqXuxRI+GWqa24F+RuCHHUdMKNblk7iT7Ap9NacXfJf/8j2QXa2eJGtN1m4/yHn+tINkC8ubuS9jN/DzbVYdqFSo2s8ShftLTFyRKRkhKzqrKl6En6Y/AsASaMzqr1m1yB7w== roblor"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJ4bzLMIpw2WK3DYhJENru2f5UEMHENnHRLpf6U8sxqkYC8m2TAN0CO9uTsDdAJuEtwETIRLkyx3B5zhdwow0fA="
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 3000 5173 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  fonts.packages = with pkgs; [
    cascadia-code
    jetbrains-mono
    ibm-plex
  ];

  environment.systemPackages = (with pkgs; [
    gparted
  ]);

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    # gnome-console
    xterm
    cheese # webcam tool
    gnome-music
    gnome-terminal
    # gedit # text editor
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    nautilus
  ]);

  services.xserver.excludePackages = [ pkgs.xterm ];

  # system.autoUpgrade.enable = true;

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 60d";
  nix.gc.dates = "weekly";

  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    #permitRootLogin = "yes";
  };

  virtualisation.podman.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    # lidSwitch = "suspend";
    extraConfig = ''
      HandlePowerKey=poweroff
      IdleAction=suspend-then-hibernate
      IdleActionSec=2m
    '';
    # extraConfig = ''
      # HandlePowerKey=poweroff
      # IdleAction=suspend
      # IdleActionSec=2m
    # '';
  };

  systemd.sleep.extraConfig = "HibernateDelaySec=6h";

  hardware.bluetooth.enable = true;

  boot.tmp.cleanOnBoot = true;
  boot.extraModprobeConfig = ''
    # Function/media keys:
    #   0: Function keys only.
    #   1: Media keys by default.
    #   2: Function keys by default.
    options hid_apple fnmode=1
    # Fix tilde/backtick key.
    # options hid_apple iso_layout=0
    # Swap Alt key and Command key.
    options hid_apple swap_opt_cmd=1

    blacklist nouveau
    options nouveau modeset=0
  '';

  boot.blacklistedKernelModules = [ "nouveau" ];

  hardware.sensor.iio.enable = true;

  hardware.graphics = 
    # let
    #   pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    # in
     {
    enable = true;
    # package = pkgs-unstable.mesa.drivers;
    # driSupport = true;
    extraPackages = with pkgs; [
      intel-media-driver
      # vaapiIntel
    ];
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  services.upower.enable = true;
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
  security.pam.services.hyprlock = {
    text = ''
      auth include login
    '';
  };

  programs.fish.enable = true;

  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 0;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0 = 85;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };

  programs.light.enable = true;

  services.psd = {
    enable = true;
    resyncTimer = "1h";
  };

  services.zerotierone.enable = true;

  programs.adb.enable = true;

  specialisation = {
    nvidia.configuration = {
      services.xserver.videoDrivers = ["nvidia"];
      
      hardware.nvidia = {
        # Modesetting is required.
        modesetting.enable = true;
        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        # Enable this if you have graphical corruption issues or application crashes after waking
        # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
        # of just the bare essentials.
        powerManagement.enable = true;
        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = true;
        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        # Currently alpha-quality/buggy, so false is currently the recommended setting.
        open = false;
        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;
        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = config.boot.kernelPackages.nvidiaPackages.production;
        # Nvidia Optimus PRIME. It is a technology developed by Nvidia to optimize
        # the power consumption and performance of laptops equipped with their GPUs.
        # It seamlessly switches between the integrated graphics,
        # usually from Intel, for lightweight tasks to save power,
        # and the discrete Nvidia GPU for performance-intensive tasks.
        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
            nvidiaBusId = "PCI:1:0:0";
            intelBusId = "PCI:0:2:0";
          };
      };

      programs.steam = {
        enable = true;
      };
    };
  };

  virtualisation.vmware.host.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "dependable-embedded-systems";
      text = ''
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0660", GROUP="dialout"
      '';

      destination = "/etc/udev/rules.d/99-esp-rusy-board.rules";
    })
  ];


}
