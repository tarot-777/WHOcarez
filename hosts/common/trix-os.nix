{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.trixOS;
  pick = names:
    builtins.filter (pkg: pkg != null)
    (map (name: lib.attrByPath (lib.splitString "." name) null pkgs) names);
in {
  options.services.trixOS = {
    enable = lib.mkEnableOption "TRIX-OS host integration";

    tor.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable local Tor client service. High-anonymity workflows should still use Whonix or Tails.";
    };

    virtualization.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable libvirt/QEMU support for isolated lab and Whonix-style VM workflows.";
    };

    containers.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable rootless Podman and OCI tooling for disposable local labs.";
    };

    ttl65.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set outgoing IPv4/IPv6 packet TTL/Hop Limit to 65 using guarded systemd oneshot rules.";
    };

    llm.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install local LLM service tooling. Services are not auto-started by default.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      (pick [
        "age"
        "sops"
        "git"
        "jq"
        "curl"
        "wget"
        "nmap"
        "tcpdump"
        "wireshark-cli"
        "qemu"
        "virt-manager"
        "libvirt"
        "podman"
        "skopeo"
        "buildah"
        "dive"
        "tor"
        "torsocks"
        "proxychains-ng"
        "llama-cpp"
        "ollama"
      ]);

    networking.firewall.enable = lib.mkDefault true;
    networking.firewall.checkReversePath = lib.mkDefault "loose";

    services.tor = lib.mkIf cfg.tor.enable {
      enable = true;
      client.enable = true;
      settings = {
        SocksPort = [{addr = "127.0.0.1"; port = 9050;}];
        ControlPort = [{addr = "127.0.0.1"; port = 9051;}];
        CookieAuthentication = true;
      };
    };

    virtualisation.libvirtd.enable = lib.mkIf cfg.virtualization.enable true;
    programs.virt-manager.enable = lib.mkIf cfg.virtualization.enable true;

    virtualisation.podman = lib.mkIf cfg.containers.enable {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    users.groups.libvirtd = lib.mkIf cfg.virtualization.enable {};

    systemd.services.trix-ttl65 = lib.mkIf cfg.ttl65.enable {
      description = "TRIX optional TTL/Hop Limit 65 normalization";
      wantedBy = ["multi-user.target"];
      after = ["network-pre.target"];
      wants = ["network-pre.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = pick ["iptables" "ip6tables" "nftables" "coreutils"];
      script = ''
        set -eu
        iptables -t mangle -C POSTROUTING -j TTL --ttl-set 65 2>/dev/null \
          || iptables -t mangle -A POSTROUTING -j TTL --ttl-set 65
        ip6tables -t mangle -C POSTROUTING -j HL --hl-set 65 2>/dev/null \
          || ip6tables -t mangle -A POSTROUTING -j HL --hl-set 65
      '';
      preStop = ''
        iptables -t mangle -D POSTROUTING -j TTL --ttl-set 65 2>/dev/null || true
        ip6tables -t mangle -D POSTROUTING -j HL --hl-set 65 2>/dev/null || true
      '';
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/trix 0750 root root - -"
      "d /var/log/trix 0750 root root - -"
    ];
  };
}
