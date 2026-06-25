{
  inputs,
  settings,
}: let
  inherit (inputs.nixpkgs) lib;

  nixpkgsConfig = {
    allowUnfree = true;
    rocmSupport = false;
    permittedInsecurePackages = [];
  };

  overlays =
    lib.optionals (inputs ? fenix && inputs.fenix ? overlays && inputs.fenix.overlays ? default) [inputs.fenix.overlays.default]
    ++ lib.optionals (inputs ? nix-alien && inputs.nix-alien ? overlays && inputs.nix-alien.overlays ? default) [inputs.nix-alien.overlays.default];

  mkPkgs = system:
    import inputs.nixpkgs {
      inherit system overlays;
      config = nixpkgsConfig;
    };

  commonSpecialArgs = {
    inherit inputs;
    flakeRoot = settings.repositoryPath;
    userName = settings.user.name;
    userEmail = settings.user.email;
    homeDirectory = settings.user.homeDirectory;
    nixosHostName = settings.defaultNixosHost;
  };

  homeSharedModules =
    lib.optionals (inputs ? catppuccin) [inputs.catppuccin.homeModules.catppuccin]
    ++ lib.optionals (inputs ? stylix) [inputs.stylix.homeModules.stylix]
    ++ lib.optionals (inputs ? nix-index-database) [inputs.nix-index-database.homeModules.nix-index]
    ++ [../home/modules/trix-os.nix];

  embeddedHomeSharedModules =
    homeSharedModules
    ++ [
      {
        nixpkgs = {
          config = nixpkgsConfig;
          inherit overlays;
        };
      }
    ];

  mkHome = {
    hostName,
    system ? settings.defaultSystem,
    genericLinux ? false,
    extraModules ? [],
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
      extraSpecialArgs =
        commonSpecialArgs
        // {
          inherit hostName;
          isNixOS = !genericLinux;
        };
      modules =
        homeSharedModules
        ++ [../home/malachi]
        ++ lib.optional genericLinux {
          targets.genericLinux.enable = true;
        }
        ++ extraModules;
    };

  nixosIntegrationModules =
    lib.optionals (inputs ? disko) [inputs.disko.nixosModules.disko]
    ++ lib.optionals (inputs ? impermanence) [inputs.impermanence.nixosModules.impermanence]
    ++ lib.optionals (inputs ? sops-nix) [inputs.sops-nix.nixosModules.sops]
    ++ lib.optionals (inputs ? home-manager) [inputs.home-manager.nixosModules.home-manager]
    ++ lib.optionals (inputs ? niri-flake) [inputs.niri-flake.nixosModules.niri]
    ++ lib.optionals (inputs ? hyprland) [inputs.hyprland.nixosModules.default]
    ++ lib.optionals (inputs ? lanzaboote) [inputs.lanzaboote.nixosModules.lanzaboote]
    ++ lib.optionals (inputs ? comin) [inputs.comin.nixosModules.comin]
    ++ lib.optionals (inputs ? microvm) [inputs.microvm.nixosModules.host]
    ++ lib.optionals (inputs ? catppuccin) [inputs.catppuccin.nixosModules.catppuccin]
    ++ lib.optionals (inputs ? stylix) [inputs.stylix.nixosModules.stylix]
    ++ lib.optionals (inputs ? nix-index-database) [inputs.nix-index-database.nixosModules.nix-index]
    ++ [../hosts/common/trix-os.nix];

  mkNixos = {
    hostName,
    system ? settings.defaultSystem,
    modules ? [],
  }:
    lib.nixosSystem {
      inherit system;
      specialArgs =
        commonSpecialArgs
        // {
          inherit hostName;
          isNixOS = true;
        };
      modules =
        [
          {
            nixpkgs.pkgs = mkPkgs system;
            catppuccin = {
              enable = false;
              autoEnable = false;
            };
          }
        ]
        ++ nixosIntegrationModules
        ++ modules
        ++ [
          {
            home-manager = {
              useGlobalPkgs = false;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              sharedModules = embeddedHomeSharedModules;
              extraSpecialArgs =
                commonSpecialArgs
                // {
                  inherit hostName;
                  isNixOS = true;
                };
              users.${settings.user.name} = import ../home/malachi;
            };
          }
        ];
    };

  homeConfigurations =
    lib.mapAttrs' (
      hostName: profile:
        lib.nameValuePair "${settings.user.name}@${hostName}" (mkHome ({
            inherit hostName;
          }
          // profile))
    )
    settings.homeProfiles;

  nixosConfigurations =
    lib.mapAttrs (
      hostName: host:
        mkNixos (host // {inherit hostName;})
    )
    settings.nixosHosts;

  extraFlakes = lib.filterAttrs (_: value: value != null) {
    colmena = inputs.colmena or null;
    morph = inputs.morph or null;
    deploy_rs = inputs."deploy-rs" or null;
    hydra = inputs.hydra or null;
    nur = inputs.nur or null;
    rnix_lsp = inputs."rnix-lsp" or null;
    sops_nix = inputs.sops-nix or null;
    agenix = inputs.agenix or null;
    nh = inputs.nh or null;
    nixvim = inputs.nixvim or null;
    stylix = inputs.stylix or null;
    trix_home_module = ../home/modules/trix-os.nix;
    trix_nixos_module = ../hosts/common/trix-os.nix;
  };
in {
  inherit
    commonSpecialArgs
    homeConfigurations
    homeSharedModules
    mkHome
    mkNixos
    mkPkgs
    nixosConfigurations
    nixpkgsConfig
    overlays
    extraFlakes
    ;
}
