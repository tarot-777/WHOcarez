# Codex prompt: get TRIX running on my laptop

Paste this into Codex from inside the repo root after pulling `trix-os-framework`.

```text
You are working in my Nix flake repo `WHOcarez`, branch `trix-os-framework`. Your job is to get the TRIX-OS layer running on this laptop safely, without deleting unrelated work, without committing secrets, and without making unsafe offensive tooling permanent by default.

Context:
- User: malachi
- Likely repo path: ~/WHOcares or ~/WHOcares!
- GitHub repo: tarot-777/WHOcarez
- Branch: trix-os-framework
- This project is a Nix/Home Manager/NixOS workstation framework.
- TRIX files added in this branch:
  - scripts/trixctl.sh
  - scripts/trix-laptop-bootstrap.sh
  - home/modules/trix-os.nix
  - hosts/common/trix-os.nix
  - shells/trix/base.nix
  - shells/trix/research.nix
  - shells/trix/redteam.nix
  - shells/trix/crypto.nix
  - shells/trix/llm.nix
  - docs/TRIX-LAPTOP-SETUP.md
  - trix/local.example.nix
  - justfile

Hard rules:
1. Do not place API keys, exchange keys, SSH keys, cookies, tokens, wallet seeds, or passwords in Git.
2. Do not make red-team tools always-on services.
3. Do not enable live crypto execution. Keep crypto mode read-only/paper unless I explicitly configure secrets later.
4. Do not pretend daily-driver Tor is the same as Whonix or Tails.
5. Preserve existing Niri/WHOcares behavior unless a change is necessary and explained.
6. Prefer minimal, reversible edits.
7. Run evaluation/build checks before switching.

First inspect:
- `pwd`
- `git status --short --branch`
- `hostname`
- `whoami`
- `ls`
- `nix --version`
- `nix flake show --all-systems`
- `nix eval --json .#lib.settings.homeProfiles | jq 'keys'`

Then decide the correct profile:
- If hostname is `laptop`, use `malachi@laptop`.
- If hostname is `hp-laptop`, use `malachi@hp-laptop`.
- If hostname is `workstation`, use `malachi@workstation`.
- If hostname is `coffin`, use `malachi@coffin`.
- If none match, do not invent a destructive NixOS host. Use the closest Home Manager genericLinux profile and report what you chose.

Run checks:
- `nix flake check --no-build`
- `nix run .#trix -- info`
- `nix run .#trix -- doctor`
- `nix develop .#trix-base --command bash -lc 'echo trix-base-ok'`

If checks fail:
- Fix syntax/evaluation problems first.
- Avoid removing whole modules unless absolutely necessary.
- If a package attr is missing, use the existing safe picker pattern or move it into a dev shell.
- Rerun checks after each fix.

When checks pass, build Home Manager first:
- `AEGIS_HOST=<host> AEGIS_PROFILE=malachi@<host> TRIX_FLAKE=$PWD nix run .#home-build`

Only after build succeeds, ask before switching if this is an interactive session. If noninteractive, print the command instead of running it:
- `AEGIS_HOST=<host> AEGIS_PROFILE=malachi@<host> TRIX_FLAKE=$PWD nix run .#home-switch`

Customization tasks:
- Make sure `whycare.trixOS.enable = true` stays enabled.
- Keep `whycare.trixOS.profile = "daily"` for a laptop unless I say this is a dedicated lab machine.
- Keep specialist use through `nix develop .#trix-research`, `.#trix-redteam`, `.#trix-crypto`, and `.#trix-llm`.
- Make browser configurable but default to Brave if already used by the repo.
- Confirm `trix` command will be installed through Home Manager.
- If host-level NixOS config is available and this is a real NixOS host, add a conservative `services.trixOS` block with virtualization/containers enabled and Tor/TTL disabled by default.

After success, print:
- exact profile used
- exact files changed
- commands run
- remaining manual command to switch, if not switched
- rollback commands
- next suggested improvements
```
