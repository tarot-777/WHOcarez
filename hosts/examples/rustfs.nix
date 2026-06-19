{ config, pkgs, lib, inputs, ... }:

# Example: opt-in rustfs service module for a NixOS host.
# Import via `imports = [ ./examples/rustfs.nix ];`
# Requires the flake input `inputs.rustfs` to be present (added to top-level flake inputs).

let
  rustfs = if lib.hasAttr "rustfs" inputs then inputs.rustfs else null;
in
{
  imports = lib.optional (rustfs != null && rustfs.nixosModules ? true) (rustfs.nixosModules.rustfs) [];

  # Minimal configuration example — adapt paths and user
  services.rustfs = lib.mkIf (rustfs != null) {
    enable = true;
    user = "rustfs";
    dataDir = "/var/lib/rustfs";
    listenAddress = "127.0.0.1";
    listenPort = 8443;
  };

  # Ensure the user exists when the service is enabled
  users.users.rustfs = lib.mkIf (rustfs != null) {
    isSystemUser = true;
    home = "/var/lib/rustfs";
    systemShell = "/bin/false";
  };
}
