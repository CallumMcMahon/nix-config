{
  description = "Nix for macOS configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    darwin,
    home-manager,
    ...
  }: let
    system = "aarch64-darwin";
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
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    airArgs = {inherit inputs pkgs-unstable;} // air;
    proArgs = {inherit inputs pkgs-unstable;} // pro;
  in {
    darwinConfigurations."${air.hostname}" = darwin.lib.darwinSystem {
      inherit system;
      specialArgs = airArgs;
      modules = [
        ./modules/personal-settings.nix
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/host-users.nix
        ./modules/clean-zsh.nix

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
      inherit system;
      specialArgs = proArgs;
      modules = [
        ./modules/work-settings.nix
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/host-users.nix
        ./modules/clean-zsh.nix

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

    # nix code formatter
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
