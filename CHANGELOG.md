# Changelog

Notable changes to the `mcfuzzy-skills` collection are recorded here.

## Unreleased

### Added

- Added the `add-cross-platform-guidance` skill, which installs cross-platform development rules into a target repository's `AGENTS.md`. It detects the supported platform set from CI matrices, manifests, and packaging configuration and requires the user to confirm it, selects the applicable non-dot-prefixed instructions file, appends or replaces a delimited section instead of rewriting existing prose, and creates `AGENTS.md` when the repository has none. Use it when a project must support Linux, macOS, and Windows, when agents keep assuming the developer's operating system, or when existing agent instructions need an OS-assumption audit.
- Added `collection/skills/add-cross-platform-guidance/references/agents-section-template.md` with the cross-platform section template, placeholder mapping, adaptation rules, placement rules, and a single-platform variant for repositories that are genuinely one-OS.
- Added `collection/skills/add-cross-platform-guidance/references/platform-detection.md` with the evidence sources ranked by strength, the detection commands, the conflict-resolution table, and the single-OS escape hatch.
- Added `collection/skills/add-cross-platform-guidance/references/platform-guide-template.md` with the 22-topic platform guide used when the repository has no existing guide to link, plus the adaptation and pre-write checks.
- Added a local development copy of the skill at `.agents/skills/add-cross-platform-guidance/`, matching the existing mirror for `doc-map`, `skill-creator`, `skill-review`, and `skill-review-updater`.
- Added the local `doc-map` skill for discovering repository documentation, interactively selecting maintained documents, assigning priorities, and creating a root-level `docmap.jsonl` reference map.
- Packaged `doc-map` under `collection/skills/doc-map/` with its document-selection, map-schema, and `AGENTS.md` reference material.
- Added `collection/skills/doc-map/README.md` with installation, workflow, JSONL record, reference, and validation guidance.
- Added support for document-map metadata covering document groups, authority, purpose, update triggers, source-of-truth status, generated artifacts, related paths, and reference-check lists.
- Added the `skill-creator`, `skill-review-updater`, `create-readme`, and `create-project-documentation` skills to the working collection.
- Added `collection/skills/create-project-documentation/references/agents-instructions.md` with the `Documentation Maintenance` section template, placeholder mapping, and placement and reconciliation rules.
- Added `collection/skills/create-project-documentation/references/readme-template.md` with the 15 essential README sections, per-section guidance, and the strict rule that dropping a section requires a recorded justification.
- Added `collection/skills/create-project-documentation/references/adr-index-template.md` with the ADR index table and the rules for keeping it complete, sorted, and in step with the records it points at.
- Added a README creation and update step to `create-project-documentation`. The README is written after the rest of the document set so it can link to the guides, ADR index, and release notes, keeps all 15 required sections, links to `CONTRIBUTING.md` and `LICENSE` when present, and requires the Getting Started commands to be verified before publication.

### Changed

- Added `add-cross-platform-guidance` to the repository README's skill list.
- Updated `create-project-documentation` to write ADRs in the MADR 3.0.0 form: `Deciders`, a `Technical Story` line, context and problem statement, decision drivers, considered options, decision outcome with positive and negative consequences, per-option `Good, because` / `Bad, because` pros and cons, and typed `Links`. The status vocabulary now includes `Rejected` and `Superseded by ADR-NNNN`, the date is documented as the last update, and records hold one decision each named `NNNN-kebab-title.md`. Step 4, the output paths, the reference list, the validation checklist, and the gotchas were updated to match, including the new rules on splitting bundled records and editing both sides when superseding.
- Replaced `collection/skills/skill-review/docs/adr/0001-skill-review-architecture.md` with six one-decision MADR records covering static heuristic scoring, the six scoring axes, the modular provider pattern, the TypeScript and tsx runtime, the portable standalone skill package, and on-disk folder presence scoring. The two-layer review architecture and its Mermaid diagram moved to the new `docs/architecture.md`, and `docs/adr/index.md` lists every record. The `skill-review` README file-layout tree, Architecture section, and changelog were updated. No script or template content changed; the records describe existing behavior.
- Removed the `AGENTS.md` documentation-upkeep step from `create-project-documentation` and deleted its `references/agents-instructions.md` template, reversing the earlier change that added them. The skill now writes documents and hands them to `doc-map`, which owns the document map and the `AGENTS.md` documentation-maintenance section. This removes a duplicated template that could drift from the `doc-map` copy and stops the two skills from writing the same section. The skill's activation description, outputs, reference list, validation checklist, and gotchas were updated to match, and the run now reports the created document paths for the handoff.
- Updated the `doc-map` skill to exclude every dot-prefixed path from discovery, selection, and mapping. Directories such as `.agents/`, `.opencode/`, `.claude/`, `.cursor/`, `.github/`, and `.vscode/`, plus root-level dotfiles, are treated as agent and tooling configuration rather than project documentation. The skill now filters them with `grep -vE '(^|/)\.'` before building the inventory, reports only the skipped-path count, blocks broad selectors and existing map entries from re-admitting them, and validates that no mapped path is dot-prefixed.
- Clarified the `doc-map` workflow's final selection confirmation gate and synchronization expectations for local and packaged skill copies.
- Expanded the repository README to describe the collection's purpose, layout, usage, development workflow, and documentation conventions.
- Updated the `doc-map` workflow to prioritize `docs/` content and conventional documents such as `README`, `CHANGELOG`, `CONTRIBUTING`, `CODE_OF_CONDUCT`, and `SECURITY` while allowing interactive overrides.
- Moved the `agent-meeting-minutes` and `skill-review` skill packages into `collection/skills/` as reusable collection entries.
- Updated `create-project-documentation` to append or reconcile a documentation-maintenance section in `AGENTS.md`, creating a root `AGENTS.md` when none exists, so generated documents stay current as the project changes. Extended its activation description to cover documentation upkeep and added matching validation and gotcha guidance.

### Fixed

- Fixed a false-positive "nested reference chain" warning in the `skill-review` rubric. The check used `[^)]+` for reference paths, which also matches newlines, so a skill that mentioned a document and loaded a reference on the same line was reported even when nothing chained. The check is now per line and only fires for two distinct reference paths on one line.

## 2026-07-18

### Added

- Added the initial skill-review audit documentation and meeting records.
- Added a portable skill-review package with embedded scripts for local auditing.

### Changed

- Refined the meeting-minutes skill with explicit process guidance, validation, gotchas, and reference material.
