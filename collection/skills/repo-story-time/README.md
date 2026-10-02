# Repo Story Time

Tell the story of a repository from its structure and Git history. The skill writes two
documents into `docs/`:

- **`REPOSITORY_SUMMARY.md`** — sober technical inventory: purpose, architecture, key
  components, technologies, data flow, ownership, verification.
- **`THE_STORY_OF_THIS_REPO.md`** — the narrative: cast, seasons, themes, fault lines,
  turning points, ghosts, and the current chapter.

The narrative is allowed to be fun. The facts underneath it are not negotiable: every
number, path, and date traces back to a command run during the analysis.

## When to use

Reach for this skill when someone asks how a codebase came to be, wants repository
archaeology, an onboarding narrative, a "why does this look like this" explainer, or a
technical write-up of a project's architecture and evolution.

Skip it for single files, single subsystems, and code reviews, and skip it when the real
task is maintaining documentation — use `doc-map` or `create-project-documentation` for that.

## Installation

Copy the skill directory into the location your assistant reads skills from:

```bash
cp -r collection/skills/repo-story-time ~/.agents/skills/
```

Keep the directory name `repo-story-time` so the frontmatter `name` and activation
behavior stay aligned.

## Requirements

- `git` — the only hard dependency.
- POSIX shell (`sh`, `dash`, `bash`) for the digest script.
- Standard `awk`, `sort`, `uniq`, `comm`, `sed`, `mktemp`. No network access, no install
  step, no `jq`.

Windows users: run the script under Git Bash or WSL. Full command mapping is in
`references/powershell-equivalents.md`.

## Usage

The skill is prompt-driven — activate it and describe the repository you want written up.
It follows a six-step workflow: scope the run, collect the evidence layer, read the code,
mine the narrative, write both documents, validate and hand off.

The digest script can also be run standalone:

```bash
scripts/repo-stats.sh --help
scripts/repo-stats.sh --scope head --top 20
scripts/repo-stats.sh --scope all --top 30
scripts/repo-stats.sh --since 12.months
scripts/repo-stats.sh --with-emails
scripts/repo-stats.sh --out /tmp/repo-digest.txt
```

| Flag | Default | Purpose |
|---|---|---|
| `--repo PATH` | `.` | Repository to inspect |
| `--since DATE` | all history | Only commits after `DATE` (`12.months`, `2026-01-01`) |
| `--scope SCOPE` | `head` | Which history: `head`, `all`, `first-parent` |
| `--with-emails` | off | Include author emails; off by default to avoid leaking PII |
| `--out FILE` | stdout only | Also write the digest to `FILE` |
| `--top N` | `20` | Rows per ranked list |

### Exit codes

| Code | Meaning | What the skill should do |
|---|---|---|
| `0` | Digest produced | Continue to the analysis phases |
| `2` | Not a Git repository | Fall back to a filesystem inventory and say Git history was unavailable |
| `3` | Digest produced, clone is shallow | Continue, but disclose that seasons, cast, and tenure are incomplete |

### Digest sections

`REPO`, `WINDOW`, `TOTALS`, `CONTRIBUTORS` (counts plus tenure), `MONTHLY`, `WEEKDAY`,
`HOURS OF DAY`, `COMMIT SUBJECT PREFIXES`, `HOT FILES` (with a noise filter and a count of
what it removed), `CHURN` (largest commits, files introduced, files retired), `SHAPE`
(merges, longest-lived paths, branches), `FILE MIX`, `LANDMARKS` (genesis, most recent,
busiest days, newest tag, mean subject length).

## Tone dials

Ask for a voice, or set it inline:

- `tone:sober` — plain technical prose for audits and onboarding packs.
- `tone:storyteller` — the default. Evocative chapters, every fact intact.
- `tone:epic` — origin-story register, still bound by the evidence rules.

Inline options: `window:full` / `window:12m`, `scope:head` / `scope:all` /
`scope:first-parent`, `digest:temp` / `digest:persist`, `emails:off` / `emails:on`.

## File layout

```text
repo-story-time/
├── README.md
├── SKILL.md
├── scripts/
│   └── repo-stats.sh                        # dependency-free POSIX digest emitter
└── references/
    ├── git-recipes.md                       # verified command cookbook
    ├── narrative-craft.md                   # voice, cast, turning points, anti-patterns
    └── powershell-equivalents.md            # Windows command mapping
```

References load on demand: the command cookbook when a phase needs a query the digest does
not produce, the craft guide when drafting prose, the PowerShell mapping on Windows.

## Rules that keep the story honest

- Every headline number must appear in a command you actually ran.
- Open the diff behind each headline claim with `git show --stat <sha>`.
- State the window, the scope, and whether dates are author (`%ad`) or committer (`%cd`).
- Report authors as log identities. Do not invent roles, personalities, or motivation, and
  do not rank people by commit count.
- Never manufacture a release arc when the repository has no tags.
- Disclose limitations: shallow clone, squashed import, non-Git repository.
- The deliverable is the file in `docs/`, not markdown pasted into the chat.

## Validation

```bash
sh -n scripts/repo-stats.sh                   # POSIX syntax check
scripts/repo-stats.sh --help                  # usage is intact
scripts/repo-stats.sh --repo /path/to/repo    # exit 0 with a digest
scripts/repo-stats.sh --repo /tmp             # exit 2 outside a repository
git diff --check                              # no whitespace damage
```

The skill's own validation checklist lives in `SKILL.md` under **Validation** and covers
traceability, disclosure, privacy, and consistency between the two documents.

## License

MIT