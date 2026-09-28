# ADR-0005: Portable Standalone Skill Package Alongside The Main Tool

- **Status:** Accepted
- **Deciders:** McFuzzySquirrel
- **Date:** 2026-07-22

**Technical Story:** Let a user run the audit from an AI agent session in any repository, without configuring CI.

## Context and Problem Statement

The CI tool requires a pipeline and platform credentials. Many users want an AI agent to run the audit autonomously inside a repository instead. How should the agent-driven entry point be delivered?

## Decision Drivers

- Adoption should be zero-config: copy one directory, `npm install`, run.
- The agent needs instructions as well as scripts, so the package must be self-contained.
- Delivery must not add version-pin friction.

## Considered Options

- A git submodule that consumers pull into their repository.
- A self-contained copy of the skill and scripts maintained alongside the main tool.

## Decision Outcome

Chosen option: "A self-contained copy of the skill and scripts maintained alongside the main tool", because copy-one-directory delivery gives zero-config adoption, which a submodule's version pinning works against.

### Positive Consequences

- A self-contained copy of the skill and scripts is maintained at `templates/skills/skill-review/`, a drop-in package with its own `package.json` that can be copied directly into `.agents/skills/skill-review/` in any project.
- Shipping the skill as a self-contained package with `SKILL.md`, scripts, and `package.json` allows zero-config adoption: copy one directory, `npm install`, done.
- Users can have an AI agent run the audit autonomously from within the repository, not just as a separate CI job.

### Negative Consequences

- `scripts/rubric.ts`, `scripts/skill-review.ts`, and `scripts/detect.ts` exist in two places and must be kept in sync.
- Synchronization is enforced only by copying during development and by diffing in CI, so a missed copy is caught by a pipeline rather than at authoring time.

## Pros and Cons of the Options

### A self-contained copy of the skill and scripts

- Good, because adoption is a directory copy with no registry, submodule, or version pin.
- Good, because the agent instructions and the scripts travel together, so the audit can run in an agent session.
- Bad, because every script change must be applied twice and drift is only caught by CI diffing.

### A git submodule

- Good, because consumers pin an exact revision and cannot silently receive a broken update.
- Bad, because it is harder to adopt than a directory copy and creates version-pin friction for users who just want to run the audit.

## Links

- Implemented by [`templates/skills/skill-review/`](../../templates/skills/skill-review/).
- Related: [ADR-0004](0004-typescript-tsx-no-compile-step.md), whose build-free run is what makes a copied folder work immediately.
- Related: [ADR-0001](0001-static-heuristic-scoring.md), which is the layer this package exposes to an agent session.
- Related: [Two-layer review architecture](../architecture.md), which describes this package as the second layer.
