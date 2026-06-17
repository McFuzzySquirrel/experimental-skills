# mcfuzzy-skills

A skill template toolkit. Currently provides **skill-review** — audit your project's skills against [agentskills.io best practices](https://agentskills.io/skill-creation/best-practices) and get inline PR guidance.

## skill-review

### Usage

```bash
# Audit specific files, print report to stdout
npm run skill-review -- --files skills/my-skill/SKILL.md

# Audit changed skill files from git diff, post to PR
npm run skill-review -- --provider github --min-score 1.5 --fail-below
```

### Providers

| Provider | Env vars needed |
|----------|----------------|
| `stdout` | none |
| `github` | `GITHUB_TOKEN`, `GITHUB_REPOSITORY`, `GITHUB_REF` |
| `gitlab` | `GITLAB_TOKEN`, `CI_PROJECT_ID`, `CI_MERGE_REQUEST_IID` |
| `ado` | `SYSTEM_ACCESSTOKEN` (preferred, OAuth bearer) or `ADO_PAT` (fallback, Basic auth). Also needs `SYSTEM_TEAMFOUNDATIONCOLLECTIONURI`, `SYSTEM_TEAMPROJECT`, `BUILD_REPOSITORY_ID`, `SYSTEM_PULLREQUEST_PULLREQUESTID` |

### CI examples

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

### Rubric

Each skill is scored 1–3 on six axes:

- **Context economy** — avoids generic fundamentals the agent already knows
- **Gotchas coverage** — concrete, environment-specific edge cases
- **Procedural clarity** — teaches *how* rather than declaring *what*
- **Progressive disclosure** — offloads reference material to `references/` or `assets/`
- **Calibration** — prescriptiveness matched to task fragility
- **Validation** — self-check steps the agent can run

## Template skill

`templates/skills/skill-review/SKILL.md` is the de-branded, generic version of the skill audit template — anyone can drop it into their project's skill directory as an AI-agent instruction.
