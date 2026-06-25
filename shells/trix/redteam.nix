{pkgs}: let
  lib = pkgs.lib;
  pick = names:
    builtins.filter (pkg: pkg != null)
    (map (name: lib.attrByPath (lib.splitString "." name) null pkgs) names);
in
  pkgs.mkShell {
    name = "trix-redteam";
    packages = pick [
      "nmap"
      "rustscan"
      "nuclei"
      "subfinder"
      "dnsx"
      "httpx"
      "ffuf"
      "gobuster"
      "feroxbuster"
      "nikto"
      "mitmproxy"
      "burpsuite"
      "wireshark-cli"
      "tcpdump"
      "termshark"
      "zmap"
      "masscan"
      "seclists"
      "whois"
      "dnsutils"
      "jq"
      "python3"
    ];
    shellHook = ''
      export TRIX_PROFILE=redteam
      export TRIX_SCOPE_FILE="''${TRIX_SCOPE_FILE:-$PWD/scope.txt}"
      echo "TRIX redteam shell: owned/authorized targets only. Put scope in $TRIX_SCOPE_FILE."
      if [[ ! -f "$TRIX_SCOPE_FILE" ]]; then
        printf '# Add explicitly authorized targets here, one per line.\n' > "$TRIX_SCOPE_FILE"
      fi
    '';
  }
