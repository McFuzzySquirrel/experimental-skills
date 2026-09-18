# Repository Guidance

This repository stores reusable AI assistant skills that are valuable in day-to-day work. Keep repository documentation aligned with the skill collection and its workflows.

## Documentation Map Maintenance

- Before changing repository structure, skill usage, or the skill development workflow, read the relevant entries in `docmap.jsonl` and then read the mapped source documents.
- Check the `high` priority documents first: `README.md` for repository purpose, layout, usage, and conventions; `CHANGELOG.md` for meaningful additions and changes.
- After changing repository purpose, layout, installation guidance, development workflow, or skill collection behavior, update every affected mapped document in the same change.
- Add a changelog entry for new skills, material skill behavior changes, documentation workflow changes, and notable packaging or validation changes.
- When a mapped document is added, removed, renamed, or changes from source to generated output, update `docmap.jsonl` in the same change.
- Keep `docmap.jsonl` paths repository-relative and preserve its document metadata, map-wide instructions, and reference-check checklist.
- Do not add excluded skill-related documentation to the map unless the user explicitly expands the map scope.

## Skill Changes

- Keep reusable skills under `collection/skills/` or `collection/agent-meeting-minutes/` and preserve each skill's directory name.
- Keep operational instructions in `SKILL.md`; place conditional supporting material in the skill's `references/` directory.
- Include concrete gotchas, validation steps, and appropriate defaults or escape hatches in skills that are added or materially changed.
- Use the skill-review workflow before treating a new or substantially changed skill as ready for reuse.

## Validation

- Run `git diff --check` before completing repository documentation changes.
- Validate `docmap.jsonl` with an available JSON parser and confirm that all mapped paths exist unless their records explicitly use `status: "missing"`.
- Review the final diff for unrelated changes and explain when a relevant document was intentionally not updated.
