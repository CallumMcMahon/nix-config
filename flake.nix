{
  description = "Nix for macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    darwin,
    home-manager,
    disko,
    nixos-facter-modules,
    ...
  }: let
    air = {
      username = "callum";
      useremail = "mcmahon.callum@gmail.com";
      hostname = "Callums-MacBook-Air";
    };
    pro = {
      username = "cam45819";
      useremail = "callum.a.mcmahon@gsk.com";
      hostname = "GSKWMGFJ62X0JYX";
    };
    het = {
      username = "callum";
      useremail = "mcmahon.callum@gmail.com";
      hostname = "hetzner-cloud";
    };
    pkgs-unstable = import nixpkgs-unstable {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };
    pkgs-unstable-linux = import nixpkgs-unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    airArgs =
      {
        inherit inputs pkgs-unstable;
        system = "aarch64-darwin";
      }
      // air;
    proArgs =
      {
        inherit inputs pkgs-unstable;
        system = "aarch64-darwin";
      }
      // pro;
    hetArgs =
      {
        inherit inputs;
        pkgs-unstable = pkgs-unstable-linux;
        system = "x86_64-linux";
      }
      // het;
  in {
    darwinConfigurations."${air.hostname}" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = airArgs;
      modules = [
        ./modules/apps.nix
        ./modules/clean-zsh.nix
        ./modules/host-users.nix
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/personal-settings.nix
        ./modules/future_search.nix

        # home manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = airArgs;
          home-manager.users.${air.username} = import ./home;
        }
      ];
    };
    darwinConfigurations."${pro.hostname}" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = proArgs;
      modules = [
        ./modules/apps.nix
        ./modules/clean-zsh.nix
        ./modules/host-users.nix
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/work-settings.nix

        # home manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = proArgs;
          home-manager.users.${pro.username} = import ./home;
        }
      ];
    };
    nixosConfigurations.hetzner-cloud = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = hetArgs;
      modules = [
        disko.nixosModules.disko
        ./hetzner/configuration.nix

        # home manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = hetArgs;
          home-manager.users.${het.username} = import ./home;
        }
      ];
    };

    # nix code formatter
    # formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
