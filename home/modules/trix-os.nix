{
  config,
  lib,
  pkgs,
  flakeRoot ? "${config.home.homeDirectory}/WHOcares!",
  hostName ? "unknown",
  userName ? config.home.username,
  ...
}: let
  cfg = config.whycare.trixOS;
  pick = names:
    builtins.filter (pkg: pkg != null)
    (map (name: lib.attrByPath (lib.splitString "." name) null pkgs) names);

  trixCli = pkgs.writeShellApplication {
    name = "trix";
    runtimeInputs = pick ["coreutils" "curl" "findutils" "git" "gnugrep" "gnused" "gnutar" "gzip" "iproute2" "jq" "nix" "procps" "util-linux" "zstd"];
    text = builtins.readFile ../../scripts/trixctl.sh;
  };

  basePackages = pick [
    "age" "alejandra" "bat" "btop" "curl" "deadnix" "delta" "direnv" "eza" "fd" "fzf" "git" "git-lfs"
    "gitleaks" "jq" "just" "lazygit" "nh" "nil" "nix-output-monitor" "nixd" "ripgrep" "shellcheck" "sops"
    "statix" "tealdeer" "tokei" "tree" "trufflehog" "wget" "xh" "yq-go" "zoxide"
  ];
  researchPackages = pick ["tor-browser" "tor" "torsocks" "proxychains-ng" "onionshare" "i2pd" "qutebrowser" "brave" "whois" "dnsutils" "amass" "theharvester" "recon-ng" "exiftool" "maigret" "sherlock"];
  redteamPackages = pick ["nmap" "rustscan" "nuclei" "subfinder" "dnsx" "httpx" "ffuf" "gobuster" "feroxbuster" "nikto" "mitmproxy" "burpsuite" "wireshark-cli" "tcpdump" "termshark" "zmap" "masscan" "seclists"];
  forensicsPackages = pick ["sleuthkit" "volatility3" "foremost" "scalpel" "binwalk" "file" "hexyl" "xxd" "radare2" "rizin" "cutter" "ghidra" "gdb"];
  llmPackages = pick ["llama-cpp" "ollama" "open-webui" "python3" "uv" "nodejs" "deno" "mods" "aichat"];
  cryptoPackages = pick ["electrum" "sparrow" "monero-cli" "monero-gui" "python3Packages.ccxt" "python3Packages.pandas" "python3Packages.requests"];

  selectedPackages =
    basePackages
    ++ lib.optionals (builtins.elem cfg.profile ["research" "full"]) researchPackages
    ++ lib.optionals (builtins.elem cfg.profile ["redteam" "full"]) redteamPackages
    ++ lib.optionals (builtins.elem cfg.profile ["forensics" "redteam" "full"]) forensicsPackages
    ++ lib.optionals (builtins.elem cfg.profile ["llm" "full"]) llmPackages
    ++ lib.optionals (builtins.elem cfg.profile ["crypto" "full"]) cryptoPackages;
in {
  options.whycare.trixOS = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the TRIX-OS daily operator layer by default.";
    };
    profile = lib.mkOption {
      type = lib.types.enum ["daily" "research" "redteam" "forensics" "llm" "crypto" "full"];
      default = "daily";
      description = "Operator profile to install into the Home Manager user environment.";
    };
    enableAliases = lib.mkOption {type = lib.types.bool; default = true;};
    browser = lib.mkOption {type = lib.types.str; default = "brave";};
    llmLocalUrl = lib.mkOption {type = lib.types.str; default = "http://127.0.0.1:8080/v1";};
    ollamaUrl = lib.mkOption {type = lib.types.str; default = "http://127.0.0.1:11434";};
  };

  config = lib.mkIf cfg.enable {
    home.packages = selectedPackages ++ [trixCli];

    home.sessionVariables = {
      TRIX_PROFILE = cfg.profile;
      TRIX_FLAKE = flakeRoot;
      TRIX_HOST = hostName;
      TRIX_USER = userName;
      TRIX_BROWSER = cfg.browser;
      TRIX_LLM_LOCAL_URL = "${cfg.llmLocalUrl}/models";
      TRIX_OLLAMA_URL = "${cfg.ollamaUrl}/api/tags";
      TRIX_STATE_DIR = "${config.home.homeDirectory}/.local/state/trix";
      TRIX_CONFIG_DIR = "${config.home.homeDirectory}/.config/trix";
    };

    xdg.configFile."trix/trix.toml".text = ''
      profile = "${cfg.profile}"
      host = "${hostName}"
      user = "${userName}"
      flake = "${flakeRoot}"
      browser = "${cfg.browser}"
      llm_local_url = "${cfg.llmLocalUrl}"
      ollama_url = "${cfg.ollamaUrl}"

      [boundaries]
      default_redteam_scope = "owned-or-explicitly-authorized"
      high_anonymity = "use Whonix VM or Tails USB, not a daily-driver browser"
      crypto_live_execution = "requires external sops/age secrets and exchange-side withdrawal lockout"
    '';

    xdg.configFile."trix/profiles.toml".text = ''
      [profiles.daily]
      purpose = "daily operator environment with CLI, Nix, secrets, and diagnostics"
      [profiles.research]
      purpose = "anonymous/deep-web research prep with Tor tooling and identity separation"
      [profiles.redteam]
      purpose = "authorized lab and assessment tooling; no background scanners"
      [profiles.forensics]
      purpose = "evidence capture, file analysis, timelines, reverse engineering"
      [profiles.llm]
      purpose = "local/cloud LLM endpoints, capture, prompts, model workflows"
      [profiles.crypto]
      purpose = "read-only and paper workflows by default; live mode secret-gated"
    '';

    programs.bash.shellAliases = lib.mkIf cfg.enableAliases {
      trixd = "trix doctor";
      trixcap = "trix capture";
      trixllm = "trix llm";
      trixghost = "trix research";
      trixred = "trix shell redteam";
      trixcrypto = "trix shell crypto";
      trixcheck = "trix repo-check";
    };

    programs.zsh.shellAliases = lib.mkIf cfg.enableAliases {
      trixd = "trix doctor";
      trixcap = "trix capture";
      trixllm = "trix llm";
      trixghost = "trix research";
      trixred = "trix shell redteam";
      trixcrypto = "trix shell crypto";
      trixcheck = "trix repo-check";
    };
  };
}
