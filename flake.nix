{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };
    rust-overlay-stable = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay-unstable = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "unstable";
    };
    alacritty-theme-stable = {
      url = "github:alexghr/alacritty-theme.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alacritty-theme-unstable = {
      url = "github:alexghr/alacritty-theme.nix";
      inputs.nixpkgs.follows = "unstable";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    lanzaboote-stable = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote-unstable = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "unstable";
    };
    agenix-stable = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-unstable = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "unstable";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    {
      self,
      nixpkgs,
      unstable,
      home-manager,
      home-manager-unstable,
      deploy-rs,
      ...
    }@inputs:
    let
      NASOptions = {
        domain = "lorenzon-cloud.ddnsfree.com";
        domainDn = "dc=lorenzon-cloud,dc=ddnsfree,dc=com";
        services = {
          immich = true;
          authelia = true;
          ente = false;
          lldap = true;
          rustfs = true;
          seafile = false;
          opencloud = true;
          onlyoffice = true;
          users = false;
        };
      };
    in
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
          inputs.lanzaboote-unstable.nixosModules.lanzaboote
          inputs.agenix-unstable.nixosModules.default
          (
            {
              config,
              pkgs,
              lib,
              ...
            }:
            {
              nix = {
                settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                registry.nixpkgs.flake = inputs.unstable;
              };
              nixpkgs.overlays = [
                inputs.rust-overlay-unstable.overlays.default
                inputs.alacritty-theme-unstable.overlays.default
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
          inputs.lanzaboote-unstable.nixosModules.lanzaboote
          inputs.agenix-unstable.nixosModules.default
          (
            { config, pkgs, ... }:
            {
              nix = {
                settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                registry.nixpkgs.flake = inputs.unstable;
              };
              nixpkgs.config.rocmSupport = true;
              nixpkgs.overlays = [
                inputs.rust-overlay-unstable.overlays.default
                inputs.alacritty-theme-unstable.overlays.default
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
      nixosConfigurations.roblor-zimaboard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          inherit NASOptions;
          variants = {
            initialVersion = "25.11";
            hostName = "roblor-zimaboard";
          };
        };
        modules = [
          inputs.lanzaboote-stable.nixosModules.lanzaboote
          inputs.agenix-stable.nixosModules.default
          (
            { config, pkgs, ... }:
            {
              nix = {
                settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                registry.nixpkgs.flake = inputs.nixpkgs;
              };
            }
          )
          ./nas
        ];
      };
      nixosConfigurations.roblor-vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          inherit NASOptions;
          variants = {
            initialVersion = "23.11";
            hostName = "roblor-vps";
          };
        };
        modules = [
          inputs.lanzaboote-stable.nixosModules.lanzaboote
          inputs.agenix-stable.nixosModules.default
          (
            { config, pkgs, ... }:
            {
              nix = {
                settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                registry.nixpkgs.flake = inputs.nixpkgs;
              };
            }
          )
          ./vps
        ];
      };

      deploy =
        let
          system = "x86_64-linux";
          # Unmodified nixpkgs
          pkgs = import nixpkgs { inherit system; };
          # nixpkgs with deploy-rs overlay but force the nixpkgs package
          deployPkgs = import nixpkgs {
            inherit system;
            overlays = [
              deploy-rs.overlays.default # or deploy-rs.overlays.default
              (self: super: {
                deploy-rs = {
                  inherit (pkgs) deploy-rs;
                  lib = super.deploy-rs.lib;
                };
              })
            ];
          };
        in
        {
          sshUser = "root"; # user to SSH in as (change to 'roblor' if root login is disabled)
          user = "root"; # user to run the activation script (usually root)

          nodes = {
            "roblor-zimaboard" = {
              hostname = "roblor-zimaboard"; # Ensure this resolves to an IP, or put the IP here

              profiles.system = {
                path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.roblor-zimaboard;
              };
            };
            "roblor-vps" = {
              hostname = "87.106.46.103"; # Ensure this resolves to an IP, or put the IP here

              profiles.system = {
                path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.roblor-vps;
              };
            };
          };
        };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
