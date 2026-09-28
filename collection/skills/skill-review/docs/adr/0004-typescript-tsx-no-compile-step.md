# ADR-0004: TypeScript With tsx At Runtime And No Compile Step

- **Status:** Accepted
- **Deciders:** McFuzzySquirrel
- **Date:** 2026-07-22

**Technical Story:** Let the audit scripts run directly from source with no build artefact.

## Context and Problem Statement

The package ships both a CI tool and a copy that users run by hand. How should the scripts be authored and executed so that a fresh clone runs without a build step?

## Decision Drivers

- A single install-then-run command must work for someone who just copied the folder.
- Type errors must still be caught in CI.
- The runtime must handle TypeScript and ESM together without a custom pipeline.

## Considered Options

- Author in TypeScript and emit JavaScript with `tsc` before running.
- Author in plain JavaScript.
- Author in TypeScript, run directly with `tsx`, and typecheck separately with `tsc --noEmit`.

## Decision Outcome

Chosen option: "Author in TypeScript, run directly with `tsx`, and typecheck separately with `tsc --noEmit`", because it gives a build-free install and run while keeping type errors caught in CI.

### Positive Consequences

- A single `npm run skill-review` invocation works without a build artefact, which matters for the portable standalone package users copy and run immediately.
- `tsx` compiles on the fly and `tsc --noEmit` enforces types in CI without producing output files that could go stale.
- Node.js ESM compatibility is handled: the package uses `"type": "module"` throughout and `tsx` handles the ESM and TypeScript combination correctly without a custom build pipeline.

### Negative Consequences

- *(Inferred; not recorded when the decision was made.)* `tsx` becomes a runtime dependency, so the tool does not run in an environment that only has Node.js available.
- *(Inferred; not recorded when the decision was made.)* Type safety depends on someone running `npm run typecheck`; a script that is never typechecked can drift from its declared types without any runtime symptom.

## Pros and Cons of the Options

### TypeScript run directly with tsx, typechecked with tsc --noEmit

- Good, because there is no build artefact to produce before the first run.
- Good, because `tsc --noEmit` still fails CI on type errors without generating files that could go stale.
- Good, because `tsx` handles the ESM plus TypeScript combination the package needs.
- Bad, because `tsx` must be installed for the tool to run at all.
- Bad, because type safety relies on typecheck being run as a separate step.

### Author in TypeScript and emit JavaScript with tsc

- Good, because the emitted JavaScript has no runtime dependency and runs anywhere Node.js runs.
- Bad, because a fresh copy does nothing until a build step runs, which is the wrong first experience for a drop-in package.
- Bad, because emitted files can go stale relative to the sources they were built from.

### Author in plain JavaScript

- Good, because it runs anywhere with no toolchain at all.
- Bad, because the provider interface and audit inputs lose compile-time checking, which is most of what makes them safe to extend.

## Links

- Implemented by [`package.json`](../../package.json) and [`tsconfig.json`](../../tsconfig.json).
- Related: [ADR-0003](0003-modular-provider-pattern.md), whose interface relies on the type checking this decision keeps.
- Related: [ADR-0005](0005-portable-standalone-skill-package.md), which depends on the build-free run.
