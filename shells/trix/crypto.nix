{pkgs}: let
  lib = pkgs.lib;
  pick = names:
    builtins.filter (pkg: pkg != null)
    (map (name: lib.attrByPath (lib.splitString "." name) null pkgs) names);
in
  pkgs.mkShell {
    name = "trix-crypto";
    packages = pick [
      "python3"
      "python3Packages.ccxt"
      "python3Packages.pandas"
      "python3Packages.requests"
      "electrum"
      "sparrow"
      "monero-cli"
      "age"
      "sops"
      "jq"
      "curl"
      "sqlite"
    ];
    shellHook = ''
      export TRIX_PROFILE=crypto
      export TRIX_CRYPTO_MODE="''${TRIX_CRYPTO_MODE:-read-only}"
      mkdir -p "$HOME/.local/state/trix/crypto"
      echo "TRIX crypto shell: mode=$TRIX_CRYPTO_MODE. Default is read-only; keep live keys in sops/age only."
    '';
  }
