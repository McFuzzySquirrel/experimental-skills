# skill-review

Audit your project's skills against [agentskills.io best practices](https://agentskills.io/skill-creation/best-practices) and get inline PR guidance.

## File layout

| File/dir | Purpose | Where it goes in your project |
|----------|---------|-------------------------------|
| `scripts/` | TypeScript audit tool | Copy or submodule the whole `skill-review/` directory |
| `ci-examples/github-actions.yml` | GitHub Actions workflow | `.github/workflows/skill-review.yml` |
| `ci-examples/azure-pipelines.yml` | Azure DevOps pipeline | `azure-pipelines.yml` (repo root) |
| `templates/skills/skill-review/` | Self-contained skill package (instruction + scripts + package.json) | Copy the whole directory to `.agents/skills/skill-review/` |

## Getting started

Requires Node.js 18+ (Node.js 20+ recommended).

### Option A: Full repo tooling (best for CI)

```bash
# 1. Add to your repo — copy the directory or use a submodule
cp -r path/to/skill-review .

# 2. Install dependencies
cd skill-review && npm install

# 3. Run against changed skill files in a PR
npx tsx scripts/skill-review.ts --provider github --min-score 1.5
```

> **Tip:** For CI, add the example workflow file to your repo (see CI examples below). The scripts dir and `package.json` must be present at the working directory root.

### Option B: Standalone skill folder (portable)

```bash
# 1. Copy only the template skill package into your skills directory
cp -r skill-review/templates/skills/skill-review .agents/skills/

# 2. Install deps inside the copied skill folder
cd .agents/skills/skill-review && npm install

# 3. Run the embedded tool against your repo (auto-detects git root)
npm run skill-review -- --provider stdout --min-score 1.5
```

## Usage

```bash
# Audit specific files, print report to stdout
npm run skill-review -- --files skills/my-skill/SKILL.md

# Audit changed skill files from git diff, post to PR
npm run skill-review -- --provider github --min-score 1.5 --fail-below
```

## Providers

| Provider | Env vars needed |
|----------|----------------|
| `stdout` | none |
| `github` | `GITHUB_TOKEN`, `GITHUB_REPOSITORY`, `GITHUB_REF` |
| `gitlab` | `GITLAB_TOKEN`, `CI_PROJECT_ID`, `CI_MERGE_REQUEST_IID` |
| `ado` | `SYSTEM_ACCESSTOKEN` (preferred, OAuth bearer) or `ADO_PAT` (fallback, Basic auth). Also needs `SYSTEM_TEAMFOUNDATIONCOLLECTIONURI`, `SYSTEM_TEAMPROJECT`, `BUILD_REPOSITORY_ID`, `SYSTEM_PULLREQUEST_PULLREQUESTID` |

## CI examples

The script is CI-agnostic — it reads git diff and standard env vars. Example workflows:

```bash
# Any CI: just run it with your provider
npm run skill-review -- --provider github --min-score 1.5 --fail-below
npm run skill-review -- --provider gitlab --min-score 1.5
npm run skill-review -- --provider ado --min-score 1.5
```

Full CI example files:

| File | CI system |
|------|-----------|
| `ci-examples/github-actions.yml` | GitHub Actions — copy to `.github/workflows/` |
| `ci-examples/azure-pipelines.yml` | Azure DevOps — copy to `azure-pipelines.yml` |

## Rubric

Each skill is scored 1–3 on six axes:

- **Context economy** — avoids generic fundamentals the agent already knows
- **Gotchas coverage** — concrete, environment-specific edge cases
- **Procedural clarity** — teaches *how* rather than declaring *what*
- **Progressive disclosure** — offloads reference material to `references/` or `assets/`
- **Calibration** — prescriptiveness matched to task fragility
- **Validation** — self-check steps the agent can run

## Template skill

`templates/skills/skill-review/` is a portable, self-contained skill package. Drop the whole directory into your project's skill directory to let your agent audit other skills autonomously and optionally run the embedded scripts directly from that folder.
