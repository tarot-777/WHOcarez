{
  description = "TRIX-OS / WHOcares! - modular Nix workstation, research, LLM, lab, and deployment framework";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://hyprland.cachix.org"
      "https://microvm.cachix.org"
      "https://numtide.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBc="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cachix = {
      url = "github:cachix/cachix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lorri = {
      url = "github:nix-community/lorri";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    direnv = {
      url = "github:direnv/direnv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:nix-community/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    morph = {
      url = "github:DBCDK/morph";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hydra = {
      url = "github:NixOS/hydra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    "rnix-lsp" = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland.git?ref=refs/tags/v0.47.0&submodules=1";
    misterio-starter = {
      url = "github:misterio77/nix-starter-configs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rustfs = {
      url = "github:rustfs/rustfs-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:nix-community/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld = {
      url = "github:nix-community/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs) lib;
    settings = import ./settings.nix;
    framework = import ./lib/framework.nix {inherit inputs settings;};
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = settings.supportedSystems;

      perSystem = {system, ...}: let
        pkgs = framework.mkPkgs system;
        defaultRoot = self.outPath;
        defaultHomeProfile = "${settings.user.name}@${settings.defaultHomeHost}";

        runtimeFlakeRef = ''
          root="''${WHOCARES_FLAKE:-}"
          if [[ -z "$root" ]]; then root="''${AEGIS_FLAKE:-}"; fi
          if [[ -z "$root" ]]; then root="''${TRIX_FLAKE:-}"; fi
          if [[ -z "$root" ]]; then
            if [[ -f "${settings.repositoryPath}/flake.nix" ]]; then
              root="${settings.repositoryPath}"
            elif [[ -f "$PWD/flake.nix" ]]; then
              root="$PWD"
            else
              root="${defaultRoot}"
            fi
          fi
          case "$root" in *:*) flake_ref="$root" ;; *) flake_ref="path:$root" ;; esac
        '';

        mkCommand = {name, runtimeInputs ? [], text}:
          pkgs.writeShellApplication {inherit name runtimeInputs text;};

        formatter = mkCommand {
          name = "whocares-fmt";
          runtimeInputs = [pkgs.alejandra];
          text = ''
            if (($# == 0)); then set -- .; fi
            exec alejandra "$@"
          '';
        };

        pipelineText = builtins.replaceStrings
          ["__WHOCARES_DEFAULT_FLAKE__" "__WHOCARES_DEFAULT_USER__" "__WHOCARES_DEFAULT_HOME_HOST__" "__WHOCARES_DEFAULT_NIXOS_HOST__" "__WHOCARES_DEFAULT_SYSTEM__"]
          [settings.repositoryPath settings.user.name settings.defaultHomeHost settings.defaultNixosHost settings.defaultSystem]
          (builtins.readFile ./scripts/whocares-pipeline.sh);

        commands = rec {
          info = mkCommand {
            name = "aegis-info";
            runtimeInputs = [pkgs.nix];
            text = ''
              ${runtimeFlakeRef}
              printf '%s\n' \
                "TRIX-OS / WHOcares! workstation framework" \
                "Root:          $root" \
                "Flake ref:     $flake_ref" \
                "Home profile:  ${defaultHomeProfile}" \
                "NixOS host:    ${settings.defaultNixosHost}" \
                "" \
                "Apps:" \
                "  nix run $flake_ref#trix -- info" \
                "  nix run $flake_ref#trix-laptop -- full" \
                "  nix run $flake_ref#pipeline -- validate" \
                "  nix run $flake_ref#home-build" \
                "  nix run $flake_ref#nixos-switch" \
                "" \
                "TRIX shells:" \
                "  nix develop $flake_ref#trix-base" \
                "  nix develop $flake_ref#trix-research" \
                "  nix develop $flake_ref#trix-redteam" \
                "  nix develop $flake_ref#trix-crypto" \
                "  nix develop $flake_ref#trix-llm"
            '';
          };

          trix = mkCommand {
            name = "trix";
            runtimeInputs = with pkgs; [coreutils curl findutils git gnugrep gnused gnutar gzip iproute2 jq nix procps util-linux zstd];
            text = builtins.readFile ./scripts/trixctl.sh;
          };

          trix-laptop = mkCommand {
            name = "trix-laptop-bootstrap";
            runtimeInputs = with pkgs; [coreutils git gnugrep jq nix openssh];
            text = builtins.readFile ./scripts/trix-laptop-bootstrap.sh;
          };

          pipeline = mkCommand {
            name = "whocares-pipeline";
            runtimeInputs = with pkgs; [coreutils git home-manager nix nixos-anywhere nixos-rebuild sudo util-linux];
            text = pipelineText;
          };

          home-build = mkCommand {
            name = "aegis-home-build";
            runtimeInputs = [pkgs.home-manager];
            text = ''
              ${runtimeFlakeRef}
              host="''${AEGIS_HOST:-${settings.defaultHomeHost}}"
              profile="''${AEGIS_PROFILE:-${settings.user.name}@$host}"
              exec home-manager build --flake "$flake_ref#$profile" "$@"
            '';
          };

          home-switch = mkCommand {
            name = "aegis-home-switch";
            runtimeInputs = [pkgs.home-manager];
            text = ''
              ${runtimeFlakeRef}
              host="''${AEGIS_HOST:-${settings.defaultHomeHost}}"
              profile="''${AEGIS_PROFILE:-${settings.user.name}@$host}"
              exec home-manager switch --flake "$flake_ref#$profile" "$@"
            '';
          };

          nixos-switch = mkCommand {
            name = "aegis-nixos-switch";
            runtimeInputs = [pkgs.nixos-rebuild pkgs.sudo];
            text = ''
              ${runtimeFlakeRef}
              host="''${AEGIS_NIXOS_HOST:-${settings.defaultNixosHost}}"
              exec sudo nixos-rebuild switch --flake "$flake_ref#$host" "$@"
            '';
          };

          nixos-install = mkCommand {
            name = "aegis-nixos-install";
            runtimeInputs = with pkgs; [coreutils nixos-anywhere util-linux];
            text = ''
              [[ $# -ge 2 ]] || { echo "Usage: nix run <flake>#nixos-install -- <host> <ssh-target> [args...]" >&2; exit 2; }
              ${runtimeFlakeRef}
              host="$1"; target="$2"; shift 2
              host_dir="$root/hosts/$host"
              [[ -d "$host_dir" ]] || { echo "unknown host: $host" >&2; exit 2; }
              if [[ ! -f "$host_dir/disko.nix" && "''${WHOCARES_INSTALL_WITHOUT_DISKO:-0}" != "1" ]]; then
                echo "refusing install without $host_dir/disko.nix" >&2
                exit 3
              fi
              exec nixos-anywhere --flake "$flake_ref#$host" "$@" "$target"
            '';
          };

          check = mkCommand {
            name = "aegis-check";
            runtimeInputs = [pkgs.nix];
            text = ''
              ${runtimeFlakeRef}
              exec nix flake check --no-build "$flake_ref" "$@"
            '';
          };

          update = mkCommand {
            name = "aegis-update";
            runtimeInputs = [pkgs.nix];
            text = ''
              ${runtimeFlakeRef}
              exec nix flake update --flake "$flake_ref" "$@"
            '';
          };
        };

        evaluation = {
          homeProfiles = builtins.attrNames settings.homeProfiles;
          nixosHosts = builtins.attrNames settings.nixosHosts;
          inherit defaultHomeProfile;
          inherit (settings) defaultNixosHost;
          trixShells = ["trix-base" "trix-research" "trix-redteam" "trix-crypto" "trix-llm"];
          trixApps = ["trix" "trix-laptop"];
        };
      in {
        inherit formatter;

        devShells = {
          aegis-dev = import ./shells/aegis-dev {inherit pkgs;};
          trix-base = import ./shells/trix/base.nix {inherit pkgs;};
          trix-research = import ./shells/trix/research.nix {inherit pkgs;};
          trix-redteam = import ./shells/trix/redteam.nix {inherit pkgs;};
          trix-crypto = import ./shells/trix/crypto.nix {inherit pkgs;};
          trix-llm = import ./shells/trix/llm.nix {inherit pkgs;};
          default = self.devShells.${system}.aegis-dev;
        };

        packages = commands // {default = commands.info;};

        apps = lib.mapAttrs (_: package: {
          type = "app";
          program = lib.getExe package;
        }) (commands // {default = commands.info;});

        checks = {
          devshell = self.devShells.${system}.aegis-dev;
          trix-base-shell = self.devShells.${system}.trix-base;
          framework-evaluation = pkgs.writeText "trix-framework-evaluation.json" (builtins.toJSON evaluation);
          source-quality = pkgs.runCommand "trix-source-quality" {
            nativeBuildInputs = with pkgs; [alejandra deadnix shellcheck statix];
            src = lib.cleanSource ./.;
          } ''
            cp -R "$src" source
            chmod -R u+w source
            cd source
            alejandra --check .
            statix check .
            deadnix --fail .
            shellcheck install.sh repair-from-documents-tree.sh scripts/whocares-pipeline.sh scripts/trixctl.sh scripts/trix-laptop-bootstrap.sh
            touch "$out"
          '';
        };
      };

      flake = {
        lib = {
          inherit settings;
          inherit (framework) mkHome mkNixos mkPkgs nixpkgsConfig;
        };
        overlays.default = lib.composeManyExtensions framework.overlays;
        inherit (framework) homeConfigurations nixosConfigurations;
        nixosModules.trix-os = ./hosts/common/trix-os.nix;
        homeModules.trix-os = ./home/modules/trix-os.nix;
      };
    };
}
