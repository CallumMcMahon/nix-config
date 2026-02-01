{
  description = "Nix for macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    darwin,
    home-manager,
    disko,
    nixos-facter-modules,
    nix-openclaw,
    sops-nix,
    ...
  }: let
    air = {
      username = "callum";
      useremail = "mcmahon.callum@gmail.com";
      hostname = "Callums-MacBook-Air";
    };
    gsk = {
      username = "cam45819";
      useremail = "callum.a.mcmahon@gsk.com";
      hostname = "GSKWMGFJ62X0JYX";
    };
    m4 = {
      username = "callum";
      useremail = "mcmahon.callum@gmail.com";
      hostname = "Callums-MacBook-Pro";
    };
    mini = {
      username = "fibonar";
      useremail = "mcmahon.callum@gmail.com";
      hostname = "Callums-Mac-Mini";
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
    m4Args =
      {
        inherit inputs pkgs-unstable;
        system = "aarch64-darwin";
      }
      // m4;
    miniArgs =
      {
        inherit inputs pkgs-unstable sops-nix nix-openclaw;
        system = "aarch64-darwin";
        miniSecretsFile = ./secrets/mini.yaml;
      }
      // mini;
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
        ./modules/zsh-xdg.nix
        ./modules/host-users.nix
        ./modules/nix-core.nix
        ./modules/mac_system.nix
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
    darwinConfigurations."${m4.hostname}" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = m4Args;
      modules = [
        ./modules/apps.nix
        ./modules/zsh-xdg.nix
        ./modules/host-users.nix
        ./modules/nix-core.nix
        ./modules/mac_system.nix
        ./modules/personal-settings.nix
        ./modules/future_search.nix

        # home manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = m4Args;
          home-manager.users.${m4.username} = {
            imports = [./home];
            home.packages = [pkgs-unstable.zed-editor];
          };
        }
      ];
    };
    darwinConfigurations."${mini.hostname}" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = miniArgs;
      modules = [
        ./modules/host-users.nix
        ./modules/nix-core.nix
        ./modules/mini-services.nix

        {
          system.stateVersion = 5;

          # Admin user for remote administration with sudo access
          users.users.callum-admin = {
            name = "callum-admin";
            home = "/Users/callum-admin";
            description = "Admin user for remote management";
            shell = nixpkgs.legacyPackages.aarch64-darwin.zsh;
          };
          
          # Passwordless sudo for admin user only (nix-darwin syntax)
          security.sudo.extraConfig = ''
            callum-admin ALL=(ALL) NOPASSWD: ALL
          '';
          
          services.tailscale = {
            enable = true;
            package = nixpkgs.legacyPackages.aarch64-darwin.tailscale;
          };
        }
        # User packages managed via standalone home-manager (homeConfigurations.mini)
      ];
    };
    darwinConfigurations."${gsk.hostname}" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = m4Args;
      modules = [
        ./modules/apps.nix
        ./modules/zsh-xdg.nix
        ./modules/host-users.nix
        ./modules/nix-core.nix
        ./modules/mac_system.nix
        ./modules/work-settings.nix

        # home manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = m4Args;
          home-manager.users.${m4.username} = import ./home;
        }
      ];
    };
    nixosConfigurations.hetzner-cloud = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = hetArgs;
      modules = [
        disko.nixosModules.disko
        ./hetzner/configuration.nix
        ./modules/nix-core.nix
        # ./modules/conduit.nix

        # home manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = hetArgs;
          home-manager.users.${het.username} = import ./home;
          home-manager.users.root = import ./home;
        }
      ];
    };

    # home-manager switch --flake .#callum@Callums-MacBook-Pro
    homeConfigurations."${m4.username}@${m4.hostname}" = home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs-darwin {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
      extraSpecialArgs = m4Args;
      modules = [
        ./home
        {home.packages = [pkgs-unstable.zed-editor];}
      ];
    };

    homeConfigurations."${mini.username}@${mini.hostname}" = home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs-darwin {
        system = "aarch64-darwin";
        config.allowUnfree = true;
        overlays = [nix-openclaw.overlays.default];
      };
      extraSpecialArgs = miniArgs;
      modules = [./home ./home/mini-sops.nix];
    };

    # nix code formatter
    # formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
