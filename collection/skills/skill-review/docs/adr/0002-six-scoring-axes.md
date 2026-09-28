# ADR-0002: Six Scoring Axes Derived From Best Practices

- **Status:** Accepted
- **Deciders:** McFuzzySquirrel
- **Date:** 2026-07-22

**Technical Story:** Score each skill file on a small, fixed set of axes that map to observed failure modes.

## Context and Problem Statement

Scoring a skill file on a single quality number gives contributors no actionable feedback. Which dimensions should the rubric measure so that a low score tells the author what to change?

## Decision Drivers

- Each axis should map to a failure mode actually observed in real skill files.
- The rubric should stay reviewable and the feedback actionable.
- Scores must remain comparable across files, so each axis needs a fixed range.

## Considered Options

- A single composite quality score.
- YAML-based rubric configuration instead of code-defined axes.
- Six axes derived from best practices, scored 1-3 each.
- A 1-5 range per axis instead of 1-3.

## Decision Outcome

Chosen option: "Six axes derived from best practices, scored 1-3 each", because each axis maps directly to an observed failure mode, and limiting to six keeps the rubric reviewable and the feedback actionable.

### Positive Consequences

- The axes map directly to observed failures: token waste, silent failures, declarative-only output, monolithic files, uniform prescriptiveness, and no verification.
- A 1-3 range maps cleanly onto needs-work, adequate, and strong, so every score carries an unambiguous verdict.
- Contributing to the rubric becomes a small, reviewable change rather than an open-ended one.

### Negative Consequences

- Six axes leave quality dimensions unchecked; nothing in the rubric measures accuracy, tone, or whether the described workflow actually works.
- *(Inferred; not recorded when the decision was made.)* Because the range stops at 3, a file that is exemplary on an axis scores the same as one that merely passes, so the tool cannot reward further improvement.

### Scoring axes

| Axis | What it measures |
|------|-----------------|
| Context economy | Absence of generic, fundamental explanations |
| Gotchas coverage | Presence of concrete, environment-specific edge cases |
| Procedural clarity | Step-by-step process with decision criteria |
| Progressive disclosure | Reference material offloaded to `references/` or `assets/` |
| Calibration | Prescriptiveness matched to task fragility |
| Validation | Self-check steps the agent can run |

## Pros and Cons of the Options

### Six axes derived from best practices, scored 1-3 each

- Good, because each axis traces to a failure mode observed in real skill files, so a low score names a real problem.
- Good, because six is few enough to keep the whole rubric readable in one sitting.
- Bad, because six axes cannot cover every way a skill file can be poor.

### A single composite quality score

- Good, because one number is trivial to display and to track over time.
- Bad, because it gives no actionable feedback; a contributor who sees 2/3 cannot tell what to change.

### YAML-based rubric configuration

- Good, because the rubric could be tuned without editing or rebuilding the tool.
- Bad, because it adds a parsing layer that makes the scoring harder to trace back to the code, which is the opposite of what [ADR-0001](0001-static-heuristic-scoring.md) requires.

### A 1-5 range per axis instead of 1-3

- Good, because finer granularity could in principle distinguish stronger work.
- Bad, because extra granularity did not improve actionability; 1/2/3 maps cleanly onto needs-work, adequate, and strong.

## Links

- Implemented by [`scripts/rubric.ts`](../../scripts/rubric.ts) and the agent rubric in [`SKILL.md`](../../SKILL.md).
- Related: [ADR-0001](0001-static-heuristic-scoring.md), which requires the rubric to be reproducible and inspectable.
- Related: [ADR-0006](0006-on-disk-folder-presence-scoring.md), which affects how two of these axes are measured.
