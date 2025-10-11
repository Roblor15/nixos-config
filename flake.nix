{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alacritty-theme = {
      url = "github:alexghr/alacritty-theme.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # anyrun.url = "github:Kirottu/anyrun";
    # anyrun.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    # hyprpaper.url = "github:hyprwm/hyprpaper";
    # hypridle = {
    #   url = "github:hyprwm/hypridle";
    # inputs.nixpkgs.follows = "nixpkgs";
    # };
    # hyprlock = {
    # url = "github:hyprwm/hyprlock";
    # inputs.nixpkgs.follows = "nixpkgs";
    # };
    # hyprland-contrib = {
    # url = "github:hyprwm/contrib";
    # inputs.nixpkgs.follows = "nixpkgs";
    # };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      unstable,
      nixpkgs,
      alacritty-theme,
      rust-overlay,
      home-manager,
      home-manager-unstable,
      # anyrun,
      lanzaboote,
      ...
    }@inputs:
    {
      nixosConfigurations.roblor-matebook = unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          variants = {
            hyprland = true;
            gnome = true;
            initialVersion = "25.05";
            hostName = "roblor-matebook";
          };
        };
        modules = [
          # (
          #   { modulesPath, ... }:
          #   {
          #     # Important! We disable home-manager's module to avoid option
          #     # definition collisions
          #     disabledModules = [ "${modulesPath}/programs/anyrun.nix" ];
          #   }
          # )
          # inputs.anyrun.homeManagerModules.default
          lanzaboote.nixosModules.lanzaboote
          (
            {
              config,
              pkgs,
              lib,
              ...
            }:
            {
              nixpkgs.overlays = [
                rust-overlay.overlays.default
                alacritty-theme.overlays.default
                # inputs.hypridle.overlays.default
                # inputs.hyprlock.overlays.default
                # inputs.hyprpaper.overlays.default
              ];
              environment.systemPackages = [
                (pkgs.rust-bin.stable.latest.default.override {
                  extensions = [ "rust-src" ];
                })
              ];
            }
          )
          home-manager-unstable.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.roblor =
                { ... }:
                {
                  imports = [
                    ./home.nix
                  ];
                };
              extraSpecialArgs = {
                # unstable = import unstable {
                #   inherit system;
                # };
                inherit inputs;
                variants = {
                  hyprland = true;
                  initialVersion = "25.05";
                  hostName = "roblor-matebook";
                };
              };
            };
          }
          ./configuration.nix
        ];
      };
      nixosConfigurations.roblor-desktop = unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          variants = {
            hyprland = true;
            gnome = true;
            initialVersion = "24.11";
            hostName = "roblor-desktop";
          };
        };
        modules = [
          lanzaboote.nixosModules.lanzaboote
          (
            { config, pkgs, ... }:
            {
              nixpkgs.overlays = [
                rust-overlay.overlays.default
                alacritty-theme.overlays.default
                # (final: prev: {
                #   rocmPackages = prev.rocmPackages // rec {
                #     clr =
                #       (prev.rocmPackages.clr.override {
                #         localGpuTargets = [ "gfx1201" ];
                #       }).overrideAttrs
                #         (oldAttrs: {
                #           passthru = oldAttrs.passthru // {
                #             gpuTargets = oldAttrs.passthru.gpuTargets ++ [ "gfx1201" ];
                #           };
                #         });
                #     rocminfo = (
                #       prev.rocmPackages.rocminfo.override {
                #         clr = clr;
                #       }
                #     );
                #     rocblas = (
                #       prev.rocmPackages.rocblas.override {
                #         clr = clr;
                #       }
                #     );
                #     rocsparse = (
                #       prev.rocmPackages.rocsparse.override {
                #         clr = clr;
                #       }
                #     );
                #     rocsolver = (
                #       prev.rocmPackages.rocsolver.override {
                #         clr = clr;
                #       }
                #     );
                #   };
                # })
                # inputs.hypridle.overlays.default
                # inputs.hyprlock.overlays.default
                # inputs.hyprpaper.overlays.default
              ];
              environment.systemPackages = [
                (pkgs.rust-bin.stable.latest.default.override {
                  extensions = [ "rust-src" ];
                })
              ];
            }
          )
          home-manager-unstable.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.roblor =
                { ... }:
                {
                  imports = [
                    ./home.nix
                  ];
                };
              extraSpecialArgs = {
                # unstable = import unstable {
                #   inherit system;
                # };
                inherit inputs;
                variants = {
                  hyprland = true;
                  gnome = false;
                  initialVersion = "24.11";
                  hostName = "roblor-desktop";
                };
              };
            };
          }
          ./configuration.nix
        ];
      };
    };
}
