# ADR-0006: On-Disk Folder Presence Informs Scoring

- **Status:** Accepted
- **Deciders:** McFuzzySquirrel
- **Date:** 2026-07-22

**Technical Story:** Score `references/`, `assets/`, and `scripts/` from on-disk presence as well as in-file references.

## Context and Problem Statement

When scoring `Progressive disclosure` and `Validation`, the tool can detect a `references/` directory only by the mentions in `SKILL.md`. A skill author may have already created `references/` and filled it with files but not yet linked them from `SKILL.md`. How should the tool treat on-disk structure that the file does not mention?

## Decision Drivers

- The score must not contradict the repository's actual structure.
- Advice must not ask for something the repository already contains.
- On-disk evidence should be sufficient to avoid a misleading score.

## Considered Options

- Score these axes from `SKILL.md` mentions only.
- Score them from both in-file references and on-disk folder presence, with folder presence counting as partial credit.

## Decision Outcome

Chosen option: "Score them from both in-file references and on-disk folder presence, with folder presence counting as partial credit", because otherwise the tool scores below the repository's real structure and recommends work that is already done.

### Positive Consequences

- The score matches the on-disk structure, so a skill with an existing `references/` directory scores at least 2 rather than 1.
- The suggestion changes from "Create a `references/` directory" to "Link your existing `references/` files in `SKILL.md` and add load triggers", which matches the state the author is actually in.
- `hasRefsDir`, `hasAssetsDir`, and `hasScriptsDir` are forwarded through `AuditInput` into the scoring and suggestion functions, so on-disk presence is no longer silently ignored.

### Negative Consequences

- *(Inferred; not recorded when the decision was made.)* A folder that exists but is never linked earns partial credit, so the tool can report a healthy score for a skill whose `references/` files are undiscoverable to an agent.
- *(Inferred; not recorded when the decision was made.)* The score now depends on filesystem state as well as file content, so a review of the diff alone no longer explains the full score.

## Pros and Cons of the Options

### Both in-file references and on-disk folder presence

- Good, because the score agrees with the repository the author actually has.
- Good, because the suggestion describes the remaining work instead of completed work.
- Bad, because partial credit can mask a `references/` directory that nothing links to.

### In-file mentions in SKILL.md only

- Good, because the score is derived entirely from the file under review, so a diff fully explains it.
- Bad, because it scored a correctly structured skill at 1 and recommended creating a directory that already existed, contradicting the repository.

## Links

- Implemented by [`scripts/detect.ts`](../../scripts/detect.ts) and [`scripts/rubric.ts`](../../scripts/rubric.ts).
- Related: [ADR-0002](0002-six-scoring-axes.md), whose `Progressive disclosure` and `Validation` axes this decision changes how are measured.
- Related: [ADR-0001](0001-static-heuristic-scoring.md), which requires the measurement to stay reproducible.
