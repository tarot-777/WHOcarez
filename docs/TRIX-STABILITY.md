# TRIX stability guide

TRIX is designed to stay reproducible under pressure. The system is modular so a broken research, crypto, LLM, or red-team package should not destroy the daily profile.

## Rules

1. **Pin everything through `flake.lock`.** Update intentionally with `nix flake update` and commit the lockfile.
2. **Keep risky/heavy tools out of the default system closure.** Use `nix develop .#trix-redteam`, `.#trix-llm`, and `.#trix-crypto` for specialist work.
3. **Use package pickers for optional packages.** TRIX modules use `lib.attrByPath` and filter missing packages so small nixpkgs changes do not instantly break evaluation.
4. **Use guarded host services.** Tor, TTL normalization, libvirt, Podman, and LLM services are options, not unconditional side effects.
5. **Never commit secrets.** Use age/sops and exchange-side key restrictions.
6. **Prefer evaluate-first workflows.** Build before switch; switch only after the evaluation and lint path is clean.

## Required checks

```sh
nix flake check --no-build
nix run .#check
nix run .#trix -- repo-check
```

## Source checks

The flake `source-quality` check runs:

- `alejandra --check .`
- `statix check .`
- `deadnix --fail .`
- `shellcheck` on install, pipeline, and TRIX CLI scripts

## Restore drill

1. Clone repo.
2. Restore SOPS/age key material.
3. Run `nix flake metadata` and `nix flake check --no-build`.
4. Build Home Manager: `nix run .#home-build`.
5. Switch Home Manager: `nix run .#home-switch`.
6. Switch NixOS only after the home build succeeds.
7. Run `trix doctor` and `trix capture` to verify post-restore state.

## Rollback

```sh
sudo nixos-rebuild switch --rollback
home-manager generations
home-manager expire-generations "30 days"
```

## Update cadence

- Small updates: weekly flake lock update and `nix flake check --no-build`.
- Big updates: branch first, run all shells, then merge.
- Desktop/compositor updates: test on laptop or VM before workstation.
- Security-tool updates: keep in dev shells unless a daily workflow absolutely requires them.
