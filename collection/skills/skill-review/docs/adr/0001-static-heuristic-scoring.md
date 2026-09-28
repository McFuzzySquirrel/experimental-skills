# ADR-0001: Static Heuristic Scoring Instead Of LLM-Based Scoring

- **Status:** Accepted
- **Deciders:** McFuzzySquirrel
- **Date:** 2026-07-22

**Technical Story:** Score agent skill files on every pull request without an external service dependency.

## Context and Problem Statement

AI agent skills need a consistent quality bar. Without automated enforcement, skill files drift toward being verbose, generic, or missing critical sections such as gotchas, validation steps, and load triggers. How should the audit determine whether a skill file meets the bar, given that it has to run in CI?

## Decision Drivers

- The audit must run on every pull request at zero marginal cost.
- The same input must always produce the same score, so regressions are visible in a diff.
- CI must not require API credentials.
- Reviewers must be able to read the implementation and know exactly what is checked.

## Considered Options

- Deterministic text heuristics: regex patterns, line counts, and section detection.
- Calling an LLM to evaluate each skill file.

## Decision Outcome

Chosen option: "Deterministic text heuristics", because it satisfies all four decision drivers: it is free, reproducible, credential-free, and inspectable.

### Positive Consequences

- The audit costs nothing and adds no latency, so it can gate every pull request.
- The same file always produces the same score, making diffs and regressions easy to identify.
- CI needs no `OPENAI_API_KEY` or similar token to run the audit step.
- Reviewers can read `scripts/rubric.ts` and understand exactly what the tool checks; there is no black box.

### Negative Consequences

- Static heuristics cannot understand semantics. A skill file could satisfy every pattern and still give bad advice, so the rubric is a floor check rather than a comprehensive review.
- Checks that are easy to state as a pattern are the only ones that can be automated, which caps what the audit can cover.

## Pros and Cons of the Options

### Deterministic text heuristics

- Good, because zero cost and zero latency make it viable on every pull request.
- Good, because reproducible scoring makes regressions identifiable from a diff.
- Good, because no secret management is needed in CI.
- Good, because the implementation is introspectable; reviewers read `scripts/rubric.ts` to see exactly what is checked.
- Bad, because the audit cannot judge whether the advice in a skill file is actually correct.
- Bad, because scoring saturates: once a file satisfies the patterns, further quality gains are invisible to the tool.

### Calling an LLM to evaluate each skill file

- Good, because semantic judgment would catch advice that is well-formed but wrong.
- Bad, because it requires API credentials in CI and a budget for every run.
- Bad, because output is not reproducible, so a score change between runs cannot be trusted as a regression.
- Bad, because the tool's behavior would not be readable from the repository.

## Links

- Implemented by [`scripts/rubric.ts`](../../scripts/rubric.ts) and [`scripts/skill-review.ts`](../../scripts/skill-review.ts).
- Related: [ADR-0002](0002-six-scoring-axes.md), which defines the axes these heuristics score.
- Related: [Two-layer review architecture](../architecture.md), which places an agent-driven layer above this floor check.
