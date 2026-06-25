{pkgs}: let
  lib = pkgs.lib;
  pick = names:
    builtins.filter (pkg: pkg != null)
    (map (name: lib.attrByPath (lib.splitString "." name) null pkgs) names);
in
  pkgs.mkShell {
    name = "trix-research";
    packages = pick [
      "tor"
      "tor-browser"
      "torsocks"
      "proxychains-ng"
      "onionshare"
      "i2pd"
      "qutebrowser"
      "brave"
      "curl"
      "httpie"
      "xh"
      "whois"
      "dnsutils"
      "amass"
      "theharvester"
      "recon-ng"
      "exiftool"
      "maigret"
      "sherlock"
      "jq"
      "ripgrep"
      "fd"
      "sqlite"
    ];
    shellHook = ''
      export TRIX_PROFILE=research
      export TRIX_BOUNDARY="Use Whonix/Tails for high-anonymity sessions; this shell is research prep tooling."
      mkdir -p "$HOME/.local/state/trix/research"
      echo "TRIX research shell: Tor/OSINT/browser tooling. Keep identities separated."
    '';
  }
