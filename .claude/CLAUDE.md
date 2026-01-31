# Nix Config Project Notes

## Configuration Philosophy

System and user configuration should be defined declaratively in Nix rather than via imperative commands. If a setting can be codified in this Nix config, prefer that over running ad-hoc commands (e.g., `git config`, `defaults write`, manual dotfile edits). Check the relevant Nix modules for the authoritative source of any configuration.

## Text Handling

Never manually repeat or regurgitate long sequences of text (>150 characters). Use programmatic methods instead (write to file, pipe to clipboard, etc.) to avoid transcription errors.
