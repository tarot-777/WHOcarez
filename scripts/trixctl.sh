#!/usr/bin/env bash
set -euo pipefail

TRIX_VERSION="0.1.0"
TRIX_STATE_DIR="${TRIX_STATE_DIR:-$HOME/.local/state/trix}"
TRIX_CONFIG_DIR="${TRIX_CONFIG_DIR:-$HOME/.config/trix}"
TRIX_FLAKE="${TRIX_FLAKE:-${WHOCARES_FLAKE:-${AEGIS_FLAKE:-$PWD}}}"

redact() {
  sed -E \
    -e 's/(api[_-]?key|token|secret|password|passwd|bearer|authorization)([=: ]+)[^[:space:]]+/\1\2<REDACTED>/Ig' \
    -e 's/(sk-[A-Za-z0-9_-]{20,})/<OPENAI_STYLE_KEY_REDACTED>/g' \
    -e 's/(gh[pousr]_[A-Za-z0-9_]{20,})/<GITHUB_TOKEN_REDACTED>/g'
}

have() { command -v "$1" >/dev/null 2>&1; }

flake_ref() {
  case "$TRIX_FLAKE" in
    *:*) printf '%s\n' "$TRIX_FLAKE" ;;
    *) printf 'path:%s\n' "$TRIX_FLAKE" ;;
  esac
}

banner() {
  cat <<'EOF'
TRIX-OS // Tactical Research & Intelligence eXecution
safe-by-default Nix framework: research | llm | redteam-lab | crypto | deploy
EOF
}

usage() {
  banner
  cat <<'EOF'

Usage: trix <command> [args]

Commands:
  info                Show TRIX identity, paths, and available profiles
  doctor              Check local dependencies and safe operational readiness
  capture [DIR]       Capture redacted host/repo context for LLM debugging
  shell <profile>     Enter a Nix dev shell: research, redteam, crypto, llm, base
  research            Open research tooling when installed; otherwise print commands
  llm                 Check local/cloud LLM endpoints and show launch hints
  crypto              Show safe read-only/paper/live workflow guardrails
  privacy-check       Check Tor SOCKS, default route, DNS tooling, and VM hints
  repo-check          Run format/lint/evaluation checks when inside the flake
  help                Show this help

Environment:
  TRIX_FLAKE=/path/to/repo      override flake root
  TRIX_STATE_DIR=~/.local/state/trix
  TRIX_CONFIG_DIR=~/.config/trix
EOF
}

info() {
  banner
  cat <<EOF

Version:        $TRIX_VERSION
Config dir:     $TRIX_CONFIG_DIR
State dir:      $TRIX_STATE_DIR
Flake:          $TRIX_FLAKE
Flake ref:      $(flake_ref)
Default shells: base research redteam crypto llm

Safety model:
  - default profile is defensive/research oriented
  - redteam tools are intended for owned or explicitly authorized targets only
  - live crypto execution requires separately managed secrets; TRIX never hardcodes keys
EOF
}

doctor() {
  banner
  local fail=0
  check() {
    local bin="$1" note="${2:-}"
    if have "$bin"; then
      printf '[ok]   %-18s %s\n' "$bin" "${note}"
    else
      printf '[miss] %-18s %s\n' "$bin" "${note}"
      fail=1
    fi
  }

  check nix "required for flake operations"
  check git "required for repo state"
  check home-manager "required for user profile switches"
  check jq "used by capture and reports"
  check rg "fast source search"
  check tor "Tor service/client when enabled"
  check torsocks "Tor-wrapped CLI checks"
  check qemu-system-x86_64 "VM lab support"
  check virsh "libvirt/Whonix support"
  check age "secret recipient management"
  check sops "encrypted secrets"
  check llama-server "local OpenAI-compatible llama.cpp server"
  check ollama "optional local model manager"

  if [[ -d "$TRIX_FLAKE/.git" ]]; then
    printf '\nRepo: %s\n' "$TRIX_FLAKE"
    git -C "$TRIX_FLAKE" status --short || true
  fi

  if [[ $fail -eq 0 ]]; then
    echo "\nTRIX doctor: all core checks found."
  else
    echo "\nTRIX doctor: some optional tools are missing; enable the matching profile/shell."
  fi
}

capture() {
  local outdir="${1:-$TRIX_STATE_DIR/captures/$(date -u +%Y%m%dT%H%M%SZ)}"
  mkdir -p "$outdir"

  {
    echo "# TRIX capture"
    date -u
    uname -a || true
    id || true
  } | redact >"$outdir/system.txt"

  {
    echo "# network"
    ip route || true
    ip -6 route || true
    resolvectl status 2>/dev/null || true
    nmcli device status 2>/dev/null || true
  } | redact >"$outdir/network.txt"

  {
    echo "# processes"
    ps auxww || true
  } | redact >"$outdir/processes.txt"

  if have nix; then
    {
      nix --version || true
      nix flake metadata "$(flake_ref)" 2>&1 || true
      nix flake show "$(flake_ref)" 2>&1 || true
    } | redact >"$outdir/nix.txt"
  fi

  if [[ -d "$TRIX_FLAKE/.git" ]]; then
    {
      git -C "$TRIX_FLAKE" status --short || true
      git -C "$TRIX_FLAKE" branch --show-current || true
      git -C "$TRIX_FLAKE" log --oneline -n 20 || true
    } | redact >"$outdir/git.txt"

    find "$TRIX_FLAKE" \
      -path '*/.git' -prune -o \
      -path '*/result' -prune -o \
      -path '*/node_modules' -prune -o \
      -maxdepth 4 -type f -print \
      | sed "s#^$TRIX_FLAKE/##" \
      | sort >"$outdir/tree.txt"
  fi

  if have zstd && have tar; then
    tar -C "$outdir/.." -I zstd -cf "$outdir.tar.zst" "$(basename "$outdir")"
    echo "capture: $outdir.tar.zst"
  else
    echo "capture: $outdir"
  fi
}

enter_shell() {
  local profile="${1:-base}"
  local shell_name
  case "$profile" in
    base|default) shell_name="trix-base" ;;
    research|ghost|deepweb) shell_name="trix-research" ;;
    redteam|red|pentest) shell_name="trix-redteam" ;;
    crypto|vault) shell_name="trix-crypto" ;;
    llm|ai) shell_name="trix-llm" ;;
    *) echo "unknown profile: $profile" >&2; exit 2 ;;
  esac
  exec nix develop "$(flake_ref)#${shell_name}" --command "$SHELL"
}

research() {
  mkdir -p "$TRIX_CONFIG_DIR/research"
  cat >"$TRIX_CONFIG_DIR/research/README.txt" <<'EOF'
TRIX research mode
- Prefer Tor Browser/Whonix/Tails for high-anonymity sessions.
- Keep daily-driver browser identities separate from research identities.
- Do not mix exchange, personal, and anonymous research sessions.
EOF
  if have tor-browser; then
    exec tor-browser
  elif have TorBrowser-Launcher; then
    exec TorBrowser-Launcher
  else
    cat <<EOF
Tor Browser is not on PATH. Try:
  nix develop $(flake_ref)#trix-research
  trix shell research
EOF
  fi
}

llm() {
  banner
  local local_url="${TRIX_LLM_LOCAL_URL:-http://127.0.0.1:8080/v1/models}"
  local ollama_url="${TRIX_OLLAMA_URL:-http://127.0.0.1:11434/api/tags}"
  echo "Checking local LLM endpoints..."
  if have curl; then
    curl -fsS "$local_url" >/dev/null && echo "[ok] llama.cpp/OpenAI endpoint: $local_url" || echo "[miss] llama.cpp/OpenAI endpoint: $local_url"
    curl -fsS "$ollama_url" >/dev/null && echo "[ok] Ollama endpoint: $ollama_url" || echo "[miss] Ollama endpoint: $ollama_url"
  fi
  cat <<EOF

Start options:
  llama-server -m /path/to/model.gguf --host 127.0.0.1 --port 8080
  ollama serve
  open-webui serve  # if packaged in your selected profile
EOF
}

crypto() {
  cat <<'EOF'
TRIX crypto workflow guardrails
1. read-only: public market data and watch-only portfolio checks
2. paper: strategy testing with fake balances and no exchange keys
3. live: explicit secrets only, never committed, never pasted into shell history

Use sops-nix/age for exchange API material. Disable withdrawal permissions on exchange keys.
EOF
}

privacy_check() {
  banner
  echo "Default route:"
  ip route get 1.1.1.1 2>/dev/null || true
  echo
  echo "Tor SOCKS check:"
  if have curl; then
    curl --socks5-hostname 127.0.0.1:9050 -fsS https://check.torproject.org/api/ip 2>/dev/null || echo "Tor SOCKS on 127.0.0.1:9050 not reachable."
  fi
  echo
  echo "VM isolation hints: use Whonix Gateway/Workstation for high-anonymity work; use Tails USB for amnesic sessions."
}

repo_check() {
  local ref="$(flake_ref)"
  nix flake check --no-build "$ref"
  if have alejandra && [[ -d "$TRIX_FLAKE" ]]; then alejandra --check "$TRIX_FLAKE"; fi
  if have statix && [[ -d "$TRIX_FLAKE" ]]; then statix check "$TRIX_FLAKE"; fi
  if have deadnix && [[ -d "$TRIX_FLAKE" ]]; then deadnix --fail "$TRIX_FLAKE"; fi
}

cmd="${1:-help}"
shift || true
case "$cmd" in
  info) info "$@" ;;
  doctor) doctor "$@" ;;
  capture) capture "$@" ;;
  shell) enter_shell "$@" ;;
  research) research "$@" ;;
  llm) llm "$@" ;;
  crypto) crypto "$@" ;;
  privacy-check) privacy_check "$@" ;;
  repo-check) repo_check "$@" ;;
  help|-h|--help) usage ;;
  *) echo "unknown command: $cmd" >&2; usage; exit 2 ;;
esac
