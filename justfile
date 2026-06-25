set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# Show commands
_default:
    @just --list

# Show flake outputs
show:
    nix flake show --all-systems

# Evaluate all flake outputs without building heavy closures
check:
    nix flake check --no-build

# Run full source-quality check
quality:
    nix build .#checks.x86_64-linux.source-quality

# Build the TRIX CLI
trix-build:
    nix build .#trix

# Run TRIX info
i:
    nix run .#trix -- info

# Run TRIX doctor
doctor:
    nix run .#trix -- doctor

# Capture redacted context for LLM debugging
capture:
    nix run .#trix -- capture

# Enter base operator shell
base:
    nix develop .#trix-base

# Enter research shell
research:
    nix develop .#trix-research

# Enter authorized red-team shell
red:
    nix develop .#trix-redteam

# Enter crypto shell
crypto:
    nix develop .#trix-crypto

# Enter LLM shell
llm:
    nix develop .#trix-llm

# Build selected Home Manager profile; override: AEGIS_HOST=laptop AEGIS_PROFILE=malachi@laptop just home-build
home-build:
    nix run .#home-build

# Switch selected Home Manager profile; override AEGIS_HOST and AEGIS_PROFILE as needed
home-switch:
    nix run .#home-switch

# Laptop bootstrap check
laptop-check:
    bash scripts/trix-laptop-bootstrap.sh check

# Pull/switch branch locally
laptop-pull:
    bash scripts/trix-laptop-bootstrap.sh pull

# Pull + build; prints safe switch command
laptop-full:
    bash scripts/trix-laptop-bootstrap.sh full
