# TRIX threat model

TRIX is a workstation framework for controlled research and lab work. It is not magic anonymity, not a substitute for legal authorization, and not a wallet/exchange security appliance by itself.

## Assets

- Git repo and flake lock
- Age/SOPS keys
- SSH and GitHub credentials
- Browser identities and cookies
- Local model cache and prompts
- Exchange API keys and portfolio data
- VM images and lab data
- Captured research notes and evidence

## Boundaries

### Daily desktop

Good for general work, coding, documentation, LLM use, and low-risk research.

Not good for high-anonymity work or identity mixing.

### Research profile

Good for Tor Browser, torsocks/proxychains, OSINT, metadata review, and controlled browsing.

High-anonymity work should move to Whonix/Tails rather than relying on a themed daily desktop.

### Red-team profile

Good for owned labs, CTFs, local ranges, and explicitly authorized assessments.

Not for unsanctioned access, persistence, credential theft, or stealth against third-party systems.

### Crypto profile

Good for market data, read-only portfolio checks, and paper trading.

Live execution must require exchange-side key restrictions, no withdrawal permissions, and external secret management.

## Controls

- TRIX CLI redacts common key/token patterns in captures.
- Specialist tools are profile/dev-shell gated.
- Host services are disabled unless explicitly enabled.
- TTL normalization is opt-in and visible in NixOS config.
- Secrets are outside Git by design.
- Whonix/Tails are treated as separate high-anonymity workflows.

## Non-goals

- No malware automation.
- No exploit chains or persistence automation.
- No stealth tooling for unauthorized access.
- No hidden background scanners.
- No hardcoded exchange keys or cloud LLM tokens.
