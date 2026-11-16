{
  description = "MKA Modular NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-agent.url = "github:JEFF7712/nix-agent";
    nix-agent.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      plasma-manager,
      sops-nix,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        "MKA-LAPTOP" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/hosts/MKA-LAPTOP/configuration.nix

            sops-nix.nixosModules.sops
            ./modules/ai/nix-agent.nix
            ./modules/networking/tailscale.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users."mka" = import ./modules/hosts/MKA-LAPTOP/home.nix;
            }
          ];
        };
      };
    };
}
