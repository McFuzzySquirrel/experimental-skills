# Repository Guidance

This repository stores reusable AI assistant skills that are valuable in day-to-day work. Keep repository documentation aligned with the skill collection and its workflows.

## Skill Changes

- Keep reusable skills under `collection/skills/` and preserve each skill's directory name.
- Keep operational instructions in `SKILL.md`; place conditional supporting material in the skill's `references/` directory.
- Include concrete gotchas, validation steps, and appropriate defaults or escape hatches in skills that are added or materially changed.
- Use the skill-review workflow before treating a new or substantially changed skill as ready for reuse.

## Validation

- Run `git diff --check` before completing repository documentation changes.
- Review the final diff for unrelated changes and explain when a relevant document was intentionally not updated.
