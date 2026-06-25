# TRIX laptop setup runbook

This is the safe path for pulling the TRIX branch onto a laptop and activating Home Manager.

## 0. Assumptions

- GitHub SSH works: `ssh -T git@github.com`
- Nix is installed and flakes are enabled.
- Repo path is either `~/WHOcares` or `~/WHOcares!`.
- User is usually `malachi`.
- Laptop host profile is usually one of: `laptop`, `hp-laptop`, `workstation`, or `coffin`.

## 1. Pull the branch

```sh
cd "$HOME"
if [ -d WHOcares/.git ]; then
  cd WHOcares
elif [ -d 'WHOcares!'/.git ]; then
  cd 'WHOcares!'
else
  git clone git@github.com:tarot-777/WHOcarez.git WHOcares
  cd WHOcares
fi

git fetch origin trix-os-framework
git switch trix-os-framework || git switch -c trix-os-framework origin/trix-os-framework
git pull --ff-only origin trix-os-framework
```

## 2. Validate before switching

```sh
nix flake show --all-systems
nix flake check --no-build
nix run .#trix -- info
nix run .#trix -- doctor
nix develop .#trix-base
```

## 3. Pick the correct Home Manager profile

List profiles:

```sh
nix eval --json .#lib.settings.homeProfiles | jq 'keys'
```

Common profiles:

```text
malachi@coffin
malachi@workstation
malachi@laptop
malachi@hp-laptop
malachi@Aegis-Dualis
```

Build first:

```sh
AEGIS_HOST=laptop AEGIS_PROFILE=malachi@laptop TRIX_FLAKE="$PWD" nix run .#home-build
```

Switch only after the build succeeds:

```sh
AEGIS_HOST=laptop AEGIS_PROFILE=malachi@laptop TRIX_FLAKE="$PWD" nix run .#home-switch
```

For the HP laptop, change `laptop` to `hp-laptop`.

## 4. Use the bootstrap helper

```sh
bash scripts/trix-laptop-bootstrap.sh pull
bash scripts/trix-laptop-bootstrap.sh check
TRIX_HOST=laptop TRIX_USER=malachi bash scripts/trix-laptop-bootstrap.sh full
```

The `full` mode intentionally prints the final switch command instead of silently switching everything.

## 5. After switching

```sh
trix info
trix doctor
trix capture
trix privacy-check
```

## 6. Enter specialist shells

```sh
trix shell research
trix shell redteam
trix shell crypto
trix shell llm
```

or directly:

```sh
nix develop .#trix-research
nix develop .#trix-redteam
nix develop .#trix-crypto
nix develop .#trix-llm
```

## 7. Customize safely

Start with `trix/local.example.nix`. Do not commit secrets. To make profile changes permanent, edit `home/malachi/default.nix` or the relevant host module and set:

```nix
whycare.trixOS = {
  enable = true;
  profile = "daily";
  browser = "brave";
  llmLocalUrl = "http://127.0.0.1:8080/v1";
  ollamaUrl = "http://127.0.0.1:11434";
};
```

Use `daily` on laptops. Use `research`, `redteam`, `crypto`, and `llm` through dev shells unless the laptop is a dedicated lab box.

## 8. Recovery

If Home Manager switch fails:

```sh
home-manager generations
home-manager switch --flake .#malachi@laptop
```

If a NixOS system switch fails:

```sh
sudo nixos-rebuild switch --rollback
```
