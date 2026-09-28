# Architecture

The `skill-review` audit ships as two complementary layers: a static heuristic tool that runs in CI or from a terminal, and an agent skill that runs on demand in an AI agent session. The diagram below shows how they relate.

```mermaid
flowchart TD
    A([skill file<br/>SKILL.md]) --> B

    subgraph Layer1["Layer 1 — Static Heuristic Tool (CI / CLI)"]
        B["rubric.ts\n(regex · line counts · section detection)"]
        B --> C["detect.ts\n(on-disk folder presence)"]
        C --> D["skill-review.ts\n(orchestrate + score)"]
        D --> E{provider}
        E -->|GitHub| F[PR comment]
        E -->|GitLab / ADO| G[Platform comment]
        E -->|stdout| H[Terminal output]
    end

    subgraph Layer2["Layer 2 — Agent Skill (on-demand, LLM-driven)"]
        I["SKILL.md\n(agent instructions)"]
        I --> J["AI agent reads each\nskill file + references"]
        J --> K["Applies same six-axis rubric\nwith semantic judgment"]
        K --> L["Audit report +\nsuggested improvements"]
        L --> M{user approval?}
        M -->|yes| N[Apply changes]
        M -->|no| O[Stop — report only]
    end

    A --> I

    style Layer1 fill:#f0f4ff,stroke:#4a6fa5
    style Layer2 fill:#f0fff4,stroke:#3a7d44
```

**Key principle:** Layer 1 is a *floor check* — fast, free, reproducible. Layer 2 is a *ceiling check* — semantic, contextual, human-in-the-loop. Neither replaces the other.

| Layer | Where | Driven by | When it runs |
|-------|-------|-----------|--------------|
| Static heuristic tool (`rubric.ts`) | CI / CLI | Regex + line counts | Every PR, zero cost |
| Agent skill (`SKILL.md`) | Agent session | LLM reasoning | On demand, human-in-the-loop |

## Decisions

The reasons behind the two layers, and behind the choices that keep them working, are recorded as one decision per record in [`docs/adr/`](adr/index.md):

- [ADR-0001: Static Heuristic Scoring Instead Of LLM-Based Scoring](adr/0001-static-heuristic-scoring.md)
- [ADR-0002: Six Scoring Axes Derived From Best Practices](adr/0002-six-scoring-axes.md)
- [ADR-0003: Modular Provider Pattern For Output Targets](adr/0003-modular-provider-pattern.md)
- [ADR-0004: TypeScript With tsx At Runtime And No Compile Step](adr/0004-typescript-tsx-no-compile-step.md)
- [ADR-0005: Portable Standalone Skill Package Alongside The Main Tool](adr/0005-portable-standalone-skill-package.md)
- [ADR-0006: On-Disk Folder Presence Informs Scoring](adr/0006-on-disk-folder-presence-scoring.md)
