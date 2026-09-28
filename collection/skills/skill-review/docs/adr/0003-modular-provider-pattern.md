# ADR-0003: Modular Provider Pattern For Output Targets

- **Status:** Accepted
- **Deciders:** McFuzzySquirrel
- **Date:** 2026-07-22

**Technical Story:** Let the audit post its report to any CI platform without coupling scoring to a platform API.

## Context and Problem Statement

The audit produces a report, but where that report goes depends on where the audit runs: a pull request comment on GitHub, GitLab, or Azure DevOps, or standard output on a developer machine. How should output delivery be separated from scoring?

## Decision Drivers

- Scoring logic should stay identical regardless of the output target.
- Adding a platform should not require changing the audit itself.
- The tool must be usable locally with no CI credentials.
- The audit should be unit-testable without a network or a platform account.

## Considered Options

- Branch on the output target inside the scoring and reporting code.
- A single monolithic script that formats and posts the report itself.
- A pluggable `Provider` interface with concrete implementations per platform.

## Decision Outcome

Chosen option: "A pluggable `Provider` interface with concrete implementations per platform", because it keeps `rubric.ts` pure and testable and confines every platform difference to one file.

### Positive Consequences

- Each CI platform has a different API for posting comments, and decoupling output from scoring keeps `rubric.ts` pure and testable.
- Adding a platform such as Bitbucket requires only a new file in `scripts/providers/` and no change to the audit logic.
- The `stdout` provider makes local runs trivially simple with no CI credentials.
- The initial monolithic implementation was split into `rubric.ts`, `detect.ts`, and `skill-review.ts`, which improved testability.

### Negative Consequences

- *(Inferred; not recorded when the decision was made.)* Every platform must be implemented and kept working independently, so a provider regression is invisible until someone runs the tool on that platform.
- *(Inferred; not recorded when the decision was made.)* The same scripts exist in both the main package and the portable template package, so a provider change must be applied twice, as described in [ADR-0005](0005-portable-standalone-skill-package.md).

## Pros and Cons of the Options

### A pluggable `Provider` interface with concrete implementations

- Good, because scoring stays pure and unit-testable with no platform account involved.
- Good, because a new platform is one file and no audit logic changes.
- Good, because the `stdout` provider makes the tool usable locally with no credentials.
- Bad, because each provider is untested until someone exercises that platform.

### Branch on the output target inside the scoring and reporting code

- Good, because it is the smallest possible design with no abstraction to learn.
- Bad, because platform APIs would leak into the scoring path, which is the part that must stay reproducible.

### A single monolithic script that formats and posts the report itself

- Good, because there is nothing to wire up and the tool runs from one file.
- Bad, because it cannot be tested without a platform account, and it was the initial implementation before being split for testability.

## Links

- Implemented by [`scripts/providers/`](../../scripts/providers/).
- Related: [ADR-0004](0004-typescript-tsx-no-compile-step.md), which keeps the provider interface type-checked without a build step.
- Related: [ADR-0005](0005-portable-standalone-skill-package.md), which duplicates the provider implementations.
