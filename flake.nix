{
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # home-manager = {
    #   url = "github:nix-community/home-manager/release-25.05";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "unstable";
    };
    alacritty-theme = {
      url = "github:alexghr/alacritty-theme.nix";
      inputs.nixpkgs.follows = "unstable";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs =
    {
      self,
      unstable,
      # nixpkgs,unstable      alacritty-theme,
      rust-overlay,
      # home-manager,
      home-manager-unstable,
      # anyrun,
      alacritty-theme,
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
              nixpkgs.config.rocmSupport = true;
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
