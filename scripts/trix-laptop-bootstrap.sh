#!/usr/bin/env bash
set -euo pipefail

repo_default="${HOME}/WHOcares"
repo="${TRIX_FLAKE:-${WHOCARES_FLAKE:-${AEGIS_FLAKE:-$repo_default}}}"
remote="${TRIX_REMOTE:-git@github.com:tarot-777/WHOcarez.git}"
branch="${TRIX_BRANCH:-trix-os-framework}"
host="${TRIX_HOST:-$(hostname 2>/dev/null || echo laptop)}"
user_name="${TRIX_USER:-${USER:-malachi}}"
mode="${1:-check}"

say() { printf '\033[1;35m[trix]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
fail() { printf '\033[1;31m[fail]\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

usage() {
  cat <<EOF
TRIX laptop bootstrap

Usage:
  trix-laptop-bootstrap.sh check
  trix-laptop-bootstrap.sh pull
  trix-laptop-bootstrap.sh build
  trix-laptop-bootstrap.sh switch-home
  trix-laptop-bootstrap.sh full

Environment:
  TRIX_FLAKE=$repo
  TRIX_REMOTE=$remote
  TRIX_BRANCH=$branch
  TRIX_HOST=$host
  TRIX_USER=$user_name

Modes:
  check        validate prerequisites and flake shape
  pull         clone/fetch/switch the TRIX branch
  build        run flake check and Home Manager build
  switch-home  activate Home Manager profile for TRIX_USER@TRIX_HOST
  full         pull + build, then print the switch command for review
EOF
}

ensure_nix() {
  have nix || fail "nix is not installed or not on PATH"
  nix --version
  if ! nix --extra-experimental-features 'nix-command flakes' flake --help >/dev/null 2>&1; then
    warn "nix-command/flakes may not be enabled. Add this to ~/.config/nix/nix.conf or /etc/nix/nix.conf:"
    warn "experimental-features = nix-command flakes"
  fi
}

ensure_repo() {
  if [[ -d "$repo/.git" ]]; then
    say "repo exists: $repo"
  else
    say "cloning $remote -> $repo"
    mkdir -p "$(dirname "$repo")"
    git clone "$remote" "$repo"
  fi
}

pull_repo() {
  ensure_repo
  git -C "$repo" fetch origin "$branch"
  if git -C "$repo" rev-parse --verify "$branch" >/dev/null 2>&1; then
    git -C "$repo" switch "$branch"
  else
    git -C "$repo" switch -c "$branch" "origin/$branch"
  fi
  git -C "$repo" pull --ff-only origin "$branch"
}

check_repo() {
  ensure_nix
  [[ -f "$repo/flake.nix" ]] || fail "no flake.nix at $repo"
  say "flake metadata"
  nix --extra-experimental-features 'nix-command flakes' flake metadata "path:$repo"
  say "flake outputs"
  nix --extra-experimental-features 'nix-command flakes' flake show "path:$repo" --all-systems
  say "TRIX info"
  nix --extra-experimental-features 'nix-command flakes' run "path:$repo#trix" -- info
}

build_repo() {
  check_repo
  say "flake check --no-build"
  nix --extra-experimental-features 'nix-command flakes' flake check --no-build "path:$repo"
  say "build TRIX CLI"
  nix --extra-experimental-features 'nix-command flakes' build "path:$repo#trix"
  say "home-manager build profile: ${user_name}@${host}"
  nix --extra-experimental-features 'nix-command flakes' run "path:$repo#home-build" -- --flake "path:$repo#${user_name}@${host}"
}

switch_home() {
  check_repo
  say "switching Home Manager profile ${user_name}@${host}"
  AEGIS_HOST="$host" AEGIS_PROFILE="${user_name}@${host}" TRIX_FLAKE="$repo" \
    nix --extra-experimental-features 'nix-command flakes' run "path:$repo#home-switch"
}

case "$mode" in
  help|-h|--help) usage ;;
  check) check_repo ;;
  pull) pull_repo ;;
  build) build_repo ;;
  switch-home) switch_home ;;
  full)
    pull_repo
    build_repo
    cat <<EOF

Next activation command, review before running:
  cd "$repo"
  AEGIS_HOST="$host" AEGIS_PROFILE="${user_name}@${host}" TRIX_FLAKE="$repo" nix run .#home-switch

After switching:
  trix doctor
  trix capture
EOF
    ;;
  *) usage; fail "unknown mode: $mode" ;;
esac
