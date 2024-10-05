{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alacritty-theme = {
      url = "github:alexghr/alacritty-theme.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hypridle = {
      url = "github:hyprwm/hypridle";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:MarceColl/zen-browser-flake";
  };

  # outputs = { self, /* unstable, */ nixpkgs, alacritty-theme, rust-overlay, home-manager, anyrun, ... }@inputs:
  outputs = { self, unstable, nixpkgs, alacritty-theme, rust-overlay, home-manager, anyrun, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.roblor-matebook = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; }; 
        modules = [
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [
              rust-overlay.overlays.default
              alacritty-theme.overlays.default
              inputs.hypridle.overlays.default
              inputs.hyprlock.overlays.default
              inputs.hyprpaper.overlays.default
            ];
            environment.systemPackages = [
              (pkgs.rust-bin.stable.latest.default.override
                {
                  extensions = [ "rust-src" ];
                })
            ];
          })
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.roblor = { ... }: {
                imports = [
                  ./home.nix
                ];
              };
              extraSpecialArgs = { 
                unstable = import unstable {
                  inherit system;
                };
                inherit inputs;
              };
            };
          }
          ./configuration.nix
        ];
      };
    };
}
