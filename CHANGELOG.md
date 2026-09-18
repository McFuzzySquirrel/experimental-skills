# Changelog

Notable changes to the `mcfuzzy-skills` collection are recorded here.

## Unreleased

### Added

- Added the local `doc-map` skill for discovering repository documentation, interactively selecting maintained documents, assigning priorities, and creating a root-level `docmap.jsonl` reference map.
- Packaged `doc-map` under `collection/skills/doc-map/` with its document-selection, map-schema, and `AGENTS.md` reference material.
- Added `collection/skills/doc-map/README.md` with installation, workflow, JSONL record, reference, and validation guidance.
- Added support for document-map metadata covering document groups, authority, purpose, update triggers, source-of-truth status, generated artifacts, related paths, and reference-check lists.
- Added the `skill-creator`, `skill-review-updater`, `create-readme`, and `create-project-documentation` skills to the working collection.

### Changed

- Expanded the repository README to describe the collection's purpose, layout, usage, development workflow, and documentation conventions.
- Updated the `doc-map` workflow to prioritize `docs/` content and conventional documents such as `README`, `CHANGELOG`, `CONTRIBUTING`, `CODE_OF_CONDUCT`, and `SECURITY` while allowing interactive overrides.
- Moved the `agent-meeting-minutes` and `skill-review` skill packages into `collection/skills/` as reusable collection entries.

## 2026-07-18

### Added

- Added the initial skill-review audit documentation and meeting records.
- Added a portable skill-review package with embedded scripts for local auditing.

### Changed

- Refined the meeting-minutes skill with explicit process guidance, validation, gotchas, and reference material.
