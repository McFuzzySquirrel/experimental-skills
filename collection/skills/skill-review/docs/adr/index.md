# Architecture Decision Records

*The durable architectural decisions for this project, one decision per record. Each record states the options considered, the choice, and the consequences accepted. See [`../architecture.md`](../architecture.md) for the system these decisions produced.*

| ADR | Title | Status | Date |
|---|---|---|---|
| [ADR-0001](0001-static-heuristic-scoring.md) | [Static Heuristic Scoring Instead Of LLM-Based Scoring](0001-static-heuristic-scoring.md) | Accepted | 2026-07-22 |
| [ADR-0002](0002-six-scoring-axes.md) | [Six Scoring Axes Derived From Best Practices](0002-six-scoring-axes.md) | Accepted | 2026-07-22 |
| [ADR-0003](0003-modular-provider-pattern.md) | [Modular Provider Pattern For Output Targets](0003-modular-provider-pattern.md) | Accepted | 2026-07-22 |
| [ADR-0004](0004-typescript-tsx-no-compile-step.md) | [TypeScript With tsx At Runtime And No Compile Step](0004-typescript-tsx-no-compile-step.md) | Accepted | 2026-07-22 |
| [ADR-0005](0005-portable-standalone-skill-package.md) | [Portable Standalone Skill Package Alongside The Main Tool](0005-portable-standalone-skill-package.md) | Accepted | 2026-07-22 |
| [ADR-0006](0006-on-disk-folder-presence-scoring.md) | [On-Disk Folder Presence Informs Scoring](0006-on-disk-folder-presence-scoring.md) | Accepted | 2026-07-22 |

## Rules

- One row per record, in identifier order, with no gaps in numbering.
- Keep each row's status and date in step with the record they point at.
- When a record is superseded, update its row to `Superseded by ADR-NNNN` and link the replacement in the same row rather than deleting the entry.
- Fill a row from the record itself rather than from memory; the index is a directory, not a summary.
