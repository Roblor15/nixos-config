{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, alacritty-theme, unstable, rust-overlay, home-manager, anyrun }@inputs:
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
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.roblor = import ./home.nix;
            home-manager.extraSpecialArgs = { 
              unstable = import unstable {
                inherit system;
              };
              inherit inputs;
            };
          }
          ./configuration.nix
        ];
      };
    };
}
