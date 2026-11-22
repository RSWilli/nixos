# CLAUDE.md

## Principles
- KISS. Smallest change that works.
- No extras nobody asked for: options, abstractions, auth, per-host special cases.
- Prefer upstream NixOS options over custom code.
- Fix root causes. No workarounds without asking first.
- If the right fix is "wait" or "change it outside Nix", say so.
- Do what was asked. Propose alternatives in one line, don't substitute them.
- Ask about environment facts instead of assuming. The user knows the setup.
- Large new module: propose a short plan + assumptions first.
- Prefer packaging from source over wrapping binaries.
- Prefer system-wide paths (`/var/lib`, `/var/cache`) over `$HOME` for service/tool state.

## Workflow
- Diagnose before editing when the cause is unclear.
- Format with `nix fmt` (alejandra).
- Verify after every change, including reverts: evaluate or build the affected host.
- If the sandbox blocks a command, say which and give the exact command to run.
- End with: what was evaluated, built, deployed, and what is still unverified.
