{
  lib,
  inputs,
  ...
}:
# Example: opt-in agenix integration for a NixOS host.
# Import this from a host by adding it to `imports = [ ./examples/agenix.nix ];`
# Requires the flake input `inputs.agenix` (added to the top-level flake inputs).
let
  agenix =
    if lib.hasAttr "agenix" inputs
    then inputs.agenix
    else null;
in {
  imports = lib.optional (agenix != null) agenix.nixosModules.agenix;

  # Example configuration — adapt to your keys and secret layout
  agenix = lib.mkIf (agenix != null) {
    secretsDir = "/etc/agenix";
    keys = {
      # Map secret names -> public key files (or SSH key IDs)
      example-secret = ["ssh-ed25519 AAAA... user@example"];
    };
  };

  # Optionally add a small activation check to ensure secrets exist after activation
  systemd.services.agenix-check = {
    description = "Verify agenix-deployed secrets are present";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.optionalString (agenix != null) ''
        test -f /etc/agenix/example-secret || { echo "agenix: missing example-secret" >&2; exit 1; }
      '';
    };
  };
}
