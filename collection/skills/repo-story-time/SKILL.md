---
name: repo-story-time
description: >
  Tell the story of a repository from its structure and Git history. Use when someone
  asks how a codebase came to be, wants repository archaeology, an onboarding narrative,
  a "why does this look like this" explainer, or a technical write-up of a project's
  architecture and evolution. Produces docs/REPOSITORY_SUMMARY.md and
  docs/THE_STORY_OF_THIS_REPO.md from evidence rather than impression.
---

# Repo Story Time

Every repository has a history and every history has a story. This skill reads the code
that exists and the commits that produced it, then writes two documents: a sober technical
inventory and a narrative account of how the project became what it is.

The narrative is allowed to be fun. The facts underneath it are not negotiable: every
number, path, and date in the story traces back to a command you ran in this session.

## When to use this skill

Use it when the request is about a repository as a whole — its architecture, its
evolution, its people, or its character. Typical phrasings: "tell me the story of this
repo", "how did this codebase get this way", "write an architecture overview", "do
repository archaeology", "put together an onboarding narrative", "what happened here".

Do not use it for a single file, a single subsystem, or a code review. Do not use it to
answer a question you could answer by reading one module. Do not use it to replace
`doc-map` or `create-project-documentation`; those maintain documents, this one tells a
story about them.

Reference material, loaded only when its condition holds:

- [git command cookbook](references/git-recipes.md "Load when a phase needs a query the digest does not produce, or a digest row needs corroborating") — verified POSIX commands for scope, windows, contributors, time buckets, file and rename analysis, deep dives, and landmarks.
- [Windows and PowerShell mapping](references/powershell-equivalents.md "Load when the session runs on Windows, PowerShell, or anywhere without POSIX awk") — direct command equivalents and the translation traps.
- [narrative craft guide](references/narrative-craft.md "Load when drafting the prose, when a voice is requested, or when a draft reads like a changelog wearing a costume") — tone dials, cast discipline, turning points, anti-patterns, and a worked example.

All three are direct children of `references/` and load nothing further. Never follow one
reference into another.

## Process

### Step 1: Scope the run

Confirm four things before touching the repository: the target repository root, the
history window, the tone dial, and whether existing files in `docs/` may be replaced.

Ask only about what the user has not already decided. If they said nothing about tone, then
use `tone:storyteller`. If nothing about the window, then use `window:full` rather than
assuming a twelve-month cut, because a short window silently deletes the project's
childhood. If either output file already exists, then read it and ask whether to replace it
or write alongside it; never overwrite either file silently.

**Output:** a stated scope line — root, window, tone, output paths — echoed back to the
user before any writing happens.

### Step 2: Collect the evidence layer

Run the bundled digest first; it is faster and more consistent than ad-hoc commands:

```bash
scripts/repo-stats.sh --scope head --top 20
```

Useful variations:

```bash
scripts/repo-stats.sh --scope all --top 30          # include remote and topic branches
scripts/repo-stats.sh --since 12.months             # recent activity only
scripts/repo-stats.sh --with-emails                 # only when the user wants identities
scripts/repo-stats.sh --out /tmp/repo-digest.txt   # persist when the run is long
```

Read the exit code. If the script exits `2`, then the path is not a Git repository: fall
back to a filesystem inventory with `git ls-files` replaced by `find`, and say plainly in
both documents that Git history was unavailable. If it exits `3`, then the clone is shallow:
the digest still prints, but seasons, cast, and tenure are incomplete, so the story must say
so instead of implying the whole life of the project. If the digest cannot run at all,
then use `references/powershell-equivalents.md` or Git Bash as a fallback; if that does not
work either, gather the same sections with plain `git log` commands. Any other nonzero
status is a real failure: report it rather than writing a story from a partial digest.

Keep the digest out of the committed documents unless the user asks for it. It is a working
artifact, usually under `digest:temp`.

**Output:** a digest covering totals, contributors, monthly and weekday rhythms, commit
prefixes, hot files, churn, branch shape, file mix, and landmarks.

### Step 3: Read the code that exists

The digest tells you when and where. Now find out what. Establish the technical inventory
that feeds `docs/REPOSITORY_SUMMARY.md`:

- **Purpose** — what problem the repository solves, in one paragraph a new joiner could
  repeat back correctly.
- **Architecture** — how the code is organized, and which boundary is load-bearing.
- **Key components** — each major module or skill, with its job and its dependents.
- **Technologies** — languages, frameworks, runtimes, and tooling, with versions where a
  file states them.
- **Data and control flow** — how information moves: what a user or caller triggers, what
  reads or writes state, what leaves the process.
- **Tests, CI, and packaging** — what is verified automatically and what is not verified
  at all. The gap is part of the story.

Prefer the repository's own documentation when it exists and is accurate; when it is
stale, prefer the code and note the drift. Use `references/git-recipes.md` for targeted
queries such as per-directory file counts or the commits that touched a single module.

**Output:** notes sufficient to write the summary without re-reading the repository.

### Step 4: Mine the narrative

Now interpret, but only from evidence you have actually collected. Look for:

- **Cast** — who appears as an author, how many commits each has, when they were active,
  and which paths they owned. Report authors as identities in the log, not as people with
  inferred job titles, motivations, or working hours you cannot see.
- **Seasons** — bursts, lulls, holidays, deadline-shaped clusters, and the busiest day.
- **Themes** — the dominant kinds of work and how the balance shifted over time.
- **Fault lines** — paths that change constantly, code that was rewritten, decisions that
  were reversed. Frequent churn is a signal, not automatically a defect.
- **Turning points** — the genesis commit, the largest change, renames and reorganizations,
  the day the project changed shape.
- **Ghosts** — paths deleted and never replaced. Say what they were, using the deletion
  commit, rather than implying they never existed.

Open the diffs behind your headline numbers before writing about them. For any claim you
intend to lead with, then run `git show --stat <sha>` or `git log -p -- <path>` and read
it. A digest row is an index entry, not a story. If a contributor has no territory in the
log, then omit that cast entry rather than inventing one.

**Output:** a short list of claims, each with the command output that supports it.

### Step 5: Write both documents

Write the files with your file-writing tool. Do not paste markdown into the chat and ask
the user to save it; the deliverable is the file, not the transcript.

`docs/REPOSITORY_SUMMARY.md` is the sober one: architecture, components, technologies,
data flow, ownership. Precise language, no throat-clearing, no narrative arc.

`docs/THE_STORY_OF_THIS_REPO.md` is the one that gets to be a story: chapters, a cast,
turning points, and a closing account of where the project stands. It still carries the
evidence: cite commit short SHAs and file paths inline, and keep a short "how this was
derived" note at the end listing the commands used, the window, and the scope.

Keep both documents in sync with each other. If the summary names a module as the core
of the system, the story must not depict it as a side experiment.

**Output:** both files written to `docs/`, each complete, neither a stub.

### Step 6: Validate and hand off

Run the checks in [Validation](#validation). Then report the two paths, the window and
scope used, and anything that limited the analysis: shallow history, a squashed import,
a missing `docs/` directory, or a repository that is not Git-based. Create `docs/` if it
does not exist, and mention that you did.

## Calibration

- `tone:sober` — plain technical prose, no chapters or character names. Use when the
  audience is an auditor, a regulator, or a new engineer who wants facts.
- `tone:storyteller` — the default. Evocative chapter titles and light narrative colour,
  with every number and path intact.
- `tone:epic` — full origin-story energy. Still bound by the evidence rules: no invented
  incidents, no invented dialogue, no invented motivations.
- `window:full` (default) versus `window:12m` — narrow only when the user asks for recent
  activity or the full history is too large to read.
- `scope:head` (default) versus `scope:all` versus `scope:first-parent` — `all` includes
  topic and remote branches, `first-parent` follows the trunk. State the choice in both
  documents.
- `digest:temp` (default) versus `digest:persist` — persist when the user wants the raw
  evidence checked in alongside the story.
- `emails:off` (default) versus `emails:on` — keep emails out of committed documents
  unless the user explicitly asks for them.
- If `scripts/repo-stats.sh` will not run on this host, then use Git Bash or WSL as the
  fallback; otherwise translate the queries with `references/powershell-equivalents.md`.
  You can also skip the script entirely and run the recipes in
  `references/git-recipes.md` by hand, at the cost of consistency.
- If the repository has no `docs/` directory, then create it and mention that you did.
- If the history is thinner than the requested chapter count, then write fewer, shorter
  chapters instead of padding.

## Gotchas

- **`git log --grep` is a basic regular expression.** `git log --grep="feat|fix|update"`
  matches nothing useful, because `|` is literal in POSIX BRE, and it fails silently. Use
  `-E` or `--extended-regexp`. In one repository measured while writing this skill, the
  same query returned 0 commits without `-E` and 15 with it.
- **"The history" is a choice you must state.** `--all`, `HEAD`, and `--first-parent` are
  three different stories: a repository measured here gave 36, 34, and 22 commits
  respectively. Pick a scope, then say which one in the documents.
- **Authors are not necessarily people.** Bots, agents, and automation accounts appear in
  the author field. Report them as what the log shows. Do not give them personalities,
  roles, or motivation, and do not award them credit for a human's decisions.
- **Squashed and imported histories lie by omission.** One commit that imported a decade of
  work produces a `MONTHLY` section with a single spike. Say the history was squashed
  rather than narrating a heroic origin.
- **No tags means no release arc.** Do not manufacture releases, versions, or milestones
  from commit subjects that merely mention versions.
- **Date basis matters near midnight.** `%ad` is when the work was written, `%cd` is when it
  landed. Month buckets shift between them. Declare which one you used; the digest uses
  `%ad` throughout.
- **Hot-file lists are noise unless filtered.** Lockfiles, build output, vendored
  directories, and source maps dominate raw churn rankings. The digest filters them and
  reports how many hits it removed, so you can say what was excluded.
- **A digest is an index, not a story.** Reading only the stats produces a confident,
  evidence-free document. Open at least one diff per headline claim.
- **Deleted paths are history too.** A file's deletion commit often explains a decision
  better than any surviving document. Include ghosts, and name the commit that removed them.
- **The deliverable is the file.** Writing the story into the chat instead of into `docs/`
  fails the task even when the prose is good.
- **Privacy.** Author emails, internal branch names, and remote URLs can all leak into a
  committed document. Default to `--with-emails` off and check the remote URL before
  quoting it.

## Output

`docs/REPOSITORY_SUMMARY.md`:

```markdown
# Repository Analysis: <name>

## Overview
What this repository is for and the problem it solves.

## Architecture
How the code is organized and which boundary carries the weight.

## Key Components
- **<component>**: responsibility, entry points, dependents.

## Technologies Used
Languages, frameworks, runtimes, tooling, with versions where stated.

## Data Flow
How information moves through the system, from trigger to effect.

## Team and Ownership
Which parts of the tree each author has historically owned.

## Verification
What tests and CI cover, and what they leave unchecked.
```

`docs/THE_STORY_OF_THIS_REPO.md`:

```markdown
# The Story of <name>

## Prologue: How This Was Told
Window, scope, and the commands used to produce this account.

## The Chronicles in Numbers
Totals, span, busiest day, rhythm of commits.

## The Cast
Contributors as the log records them, with tenure and territory.

## The Seasons
When the work happened, and what the quiet stretches mean.

## The Great Themes
The dominant kinds of work and how the balance shifted.

## The Fault Lines
Paths that kept changing, and what that suggests.

## Turning Points
Genesis, the largest change, reorganizations, reversals.

## Ghosts
What was deleted, when, and in which commit.

## The Current Chapter
Where the repository stands, what is growing, what looks thin.
```

Chapter titles may vary with the tone dial. The sections may not.

## Validation

Self-check before reporting the work as finished.

- [ ] Both files exist at `docs/REPOSITORY_SUMMARY.md` and `docs/THE_STORY_OF_THIS_REPO.md`, and neither is a stub.
- [ ] Every headline number in the story matches the digest; no figure appears that you did not collect.
- [ ] Each major claim is traceable to a commit short SHA, a file path, or a command you ran.
- [ ] The window, scope, and date basis are stated in the story's prologue.
- [ ] Limitations are disclosed: shallow history, squashed import, non-Git repository, or an absent `docs/` directory.
- [ ] No author email, token, secret, or internal-only host appears in either document unless the user asked for it.
- [ ] The summary and the story agree about which components matter.
- [ ] Bot and agent accounts are described as log identities, not as people with invented roles.
- [ ] Nothing was overwritten without confirmation.

Verify the digest script still behaves when you touch it:

```bash
sh -n scripts/repo-stats.sh                      # POSIX syntax
scripts/repo-stats.sh --help                     # usage is intact
scripts/repo-stats.sh --repo /path/to/repo       # exit 0 with a digest
scripts/repo-stats.sh --repo /tmp                # exit 2 outside a repository
git diff --check                                 # no whitespace damage
```

These are checks, not instructions to rewrite files.