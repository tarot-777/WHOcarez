# TRIX-OS implementation guide

TRIX-OS is implemented as a layered Nix framework, not as a monolithic security distro. The uploaded research report recommended a flake monorepo with Core, Desktop, Capabilities, and Profiles; this branch turns that into concrete files and flake outputs.

## Architecture

```text
flake.nix
├── lib/framework.nix                  # mkPkgs, mkHome, mkNixos, shared modules
├── home/modules/trix-os.nix           # user profile, packages, aliases, CLI config
├── hosts/common/trix-os.nix           # host services: Tor, libvirt, Podman, TTL option
├── scripts/trixctl.sh                 # operator CLI
├── shells/trix/base.nix               # stable Nix/operator shell
├── shells/trix/research.nix           # Tor/OSINT/research shell
├── shells/trix/redteam.nix            # authorized lab/red-team shell
├── shells/trix/crypto.nix             # crypto research/read-only shell
├── shells/trix/llm.nix                # local/cloud LLM shell
└── docs/                              # threat model, stability, rollout
```

## Profiles

- `daily`: always-on basics: Nix, Git, secrets, checks, redacted capture, CLI.
- `research`: Tor Browser, torsocks/proxychains, OSINT and metadata tools.
- `redteam`: scanners and assessment tools in an explicit authorization shell.
- `forensics`: evidence, file, reverse engineering, and timeline tooling.
- `llm`: llama.cpp/Ollama/Open WebUI-compatible local/cloud workflow tools.
- `crypto`: read-only/paper workflow helpers with secrets kept outside Git.
- `full`: all Home Manager packages for a dedicated lab box.

## Commands

```sh
nix run .#trix -- info
nix run .#trix -- doctor
nix run .#trix -- capture
nix run .#trix -- repo-check
nix develop .#trix-redteam
nix develop .#trix-research
nix develop .#trix-llm
```

## Host enablement

Add this to a NixOS host when you want host-level services:

```nix
{
  services.trixOS = {
    enable = true;
    virtualization.enable = true;
    containers.enable = true;
    tor.enable = true;
    ttl65.enable = false;
  };
}
```

## Home profile override

```nix
{
  whycare.trixOS = {
    enable = true;
    profile = "daily";
  };
}
```

## Secrets

TRIX expects secrets to be handled by `sops-nix`, `age`, `agenix`, a password manager, or exchange-side key management. Do not place cloud LLM tokens, exchange keys, SSH keys, cookies, or browser profile secrets in Git.

## Stability checklist

Run these before switching:

```sh
nix flake check --no-build
nix run .#check
nix run .#trix -- repo-check
nix develop .#trix-base
```

For deployment:

```sh
nix run .#home-build
nix run .#home-switch
nix run .#nixos-switch
```

For rollback:

```sh
sudo nixos-rebuild switch --rollback
home-manager generations
home-manager switch --flake .#malachi@coffin
```
