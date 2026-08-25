# Security Policy

WHOcares! is a personal workstation framework, not a maintained product with
an SLA — but if you find a real security issue (a privilege-escalation path
in a module, a broken signature check in the Whonix controller, a secret
that leaked into the repo), please report it privately rather than opening a
public issue.

## Reporting

Use GitHub's private vulnerability reporting for this repository
(**Security → Report a vulnerability** in the repo's sidebar) so the report
isn't public before there's a fix. If that isn't available, open an issue
that says only "possible security issue, please contact me" with no
technical detail, and wait for a response before sharing specifics.

## Scope

In scope: this repository's own Nix expressions and shell scripts,
including the Whonix signature-verification path in
`home/modules/whonix.nix` and the guarded pipeline in
`scripts/whocares-pipeline.sh`.

Out of scope: vulnerabilities in third-party software this framework can
deploy (nixpkgs packages, Whonix itself, Niri, etc.) — report those to the
relevant upstream project instead.
