# Agent Instructions

This repository manages Gmail filters with `gmailctl`.

- Do not apply filters locally unless Evan explicitly asks.
- Changes are applied by the GitHub Actions workflow after commits are pushed to `main`.
- When filter changes are ready to apply, commit them and push the branch.
- Prefer small, focused filter changes that match the existing Jsonnet style.
- Before committing filter changes, validate with a read-only command such as `gmailctl export`; avoid `gmailctl apply`.
