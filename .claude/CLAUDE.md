# Nix Config Project Notes

<!-- This file is committed to a public repo. Do not document private details (paths, hostnames, IPs, credentials, etc.). Use CLAUDE.local.md for machine-specific or private information. -->

## Configuration Philosophy

System and user configuration should be defined declaratively in Nix rather than via imperative commands. If a setting can be codified in this Nix config, prefer that over running ad-hoc commands (e.g., `git config`, `defaults write`, manual dotfile edits). Check the relevant Nix modules for the authoritative source of any configuration.

## Text Handling

Never manually repeat or regurgitate long sequences of text (>150 characters). Use programmatic methods instead (write to file, pipe to clipboard, etc.) to avoid transcription errors.

## Debugging Hosted Services

When debugging failures in hosted/remote services, prefer checking logs via SSH rather than using Chrome browser automation. Use browser inspection only as a last resort.

## Skills Documentation

When documenting solutions in skill files, link to related skills rather than duplicating information. Reference format: `(see skill: <skill-name>, "<section>" section)`. This keeps documentation DRY and makes updates easier to maintain.
