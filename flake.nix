{
  nixConfig = {
    extra-substituters = [
  		"https://hyprland.cachix.org"
      "https://ros.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
			"hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, hyprland, rust-overlay, home-manager }@inputs:
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

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
          ./configuration.nix
        ];
      };
    };
}
