# TRIX-OS

**TRIX-OS** is the TRIX layer inside WHOcarez: a modular NixOS/Home Manager framework for laptop and workstation deployment, LLM-assisted operations, privacy research, authorized lab/red-team tooling, crypto research, and reproducible restore.

The project is deliberately **safe-by-default**:

- the daily profile installs diagnostics, Nix, secrets, capture, and repo tooling;
- research/red-team/crypto/LLM capability sets are explicit profiles and dev shells;
- high-anonymity work is documented as a Whonix/Tails boundary, not falsely simulated inside a daily-driver browser;
- live exchange execution is secret-gated and never hardcoded;
- red-team tooling is scoped to owned or explicitly authorized systems.

## Flake outputs

```sh
nix run .#trix -- info
nix run .#trix -- doctor
nix run .#trix -- capture
nix develop .#trix-base
nix develop .#trix-research
nix develop .#trix-redteam
nix develop .#trix-crypto
nix develop .#trix-llm
```

## Home Manager module

The Home Manager module is `home/modules/trix-os.nix`. It is imported through `lib/framework.nix` as a shared module and defaults to the `daily` profile. Override it per host or user:

```nix
{
  whycare.trixOS = {
    enable = true;
    profile = "research"; # daily, research, redteam, forensics, llm, crypto, full
    browser = "brave";
    llmLocalUrl = "http://127.0.0.1:8080/v1";
    ollamaUrl = "http://127.0.0.1:11434";
  };
}
```

## NixOS module

The NixOS module is `hosts/common/trix-os.nix`. It exposes guarded host-level switches:

```nix
{
  services.trixOS = {
    enable = true;
    tor.enable = false;
    virtualization.enable = true;
    containers.enable = true;
    ttl65.enable = false;
    llm.enable = false;
  };
}
```

## Operator CLI

`scripts/trixctl.sh` builds the `trix` command. It performs actual actions:

- `trix doctor` checks tool availability;
- `trix capture` creates a redacted diagnostic archive under `~/.local/state/trix/captures`;
- `trix shell redteam` enters the matching flake shell;
- `trix llm` checks llama.cpp/Ollama-style endpoints;
- `trix privacy-check` checks route and Tor SOCKS availability;
- `trix repo-check` runs flake and lint checks.

## Stability rules

1. Keep `flake.lock` committed.
2. Keep dangerous/heavy tooling profile-gated.
3. Prefer `nix develop .#trix-*` over permanent installation for specialist tooling.
4. Use `sops-nix`/`age` for secrets.
5. Run `nix flake check --no-build` before switching hosts.
6. Use Whonix/Tails for high-anonymity work instead of mixing identities in the daily desktop.
