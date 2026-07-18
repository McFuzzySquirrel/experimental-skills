# mcfuzzy-skills

A collection of skill template projects for AI assistants. Each subdirectory is a self-contained skill project.

## Highlights

- `skill-review` now includes a portable skill package at `skill-review/templates/skills/skill-review/`.
- You can copy only that directory into `.agents/skills/` and run its embedded audit scripts locally.

## Projects

| Project | Description |
|---------|-------------|
| [`agent-meeting-minutes/`](agent-meeting-minutes/) | Turn conversations into structured meeting minutes with decisions, action items, and open questions |
| [`skill-review/`](skill-review/) | Audit skills against [agentskills.io best practices](https://agentskills.io/skill-creation/best-practices) and post inline PR guidance. Includes a standalone skill package with embedded scripts. |

## Quick Start: Portable Skill Install

Requires Node.js 18+ (Node.js 20+ recommended).

```bash
cp -r skill-review/templates/skills/skill-review .agents/skills/
cd .agents/skills/skill-review
npm install
npm run skill-review -- --provider stdout --min-score 1.5
```

See [`skill-review/README.md`](skill-review/README.md) for full setup options and CI usage.

## License

MIT
