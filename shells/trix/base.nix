{pkgs}: let
  lib = pkgs.lib;
  pick = names:
    builtins.filter (pkg: pkg != null)
    (map (name: lib.attrByPath (lib.splitString "." name) null pkgs) names);
in
  pkgs.mkShell {
    name = "trix-base";
    packages = pick [
      "age"
      "alejandra"
      "bat"
      "btop"
      "curl"
      "deadnix"
      "direnv"
      "eza"
      "fd"
      "fzf"
      "git"
      "gitleaks"
      "jq"
      "nh"
      "nil"
      "nix-output-monitor"
      "nixd"
      "ripgrep"
      "shellcheck"
      "sops"
      "statix"
      "tealdeer"
      "tokei"
      "tree"
      "trufflehog"
      "xh"
      "yq-go"
      "zoxide"
      "zstd"
    ];
    shellHook = ''
      export TRIX_PROFILE=base
      export TRIX_STATE_DIR="''${TRIX_STATE_DIR:-$HOME/.local/state/trix}"
      export TRIX_CONFIG_DIR="''${TRIX_CONFIG_DIR:-$HOME/.config/trix}"
      mkdir -p "$TRIX_STATE_DIR" "$TRIX_CONFIG_DIR"
      echo "TRIX base shell: Nix, secrets, repo checks, capture, and diagnostics."
    '';
  }
