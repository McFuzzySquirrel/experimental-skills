# Narrative Craft

> Load when: drafting the story, when the user asks for a specific voice, when a draft reads
> like a changelog wearing a costume, or when a chapter has to carry real technical weight
> without becoming dry.

## The bargain

Fun in the telling. Exact in the facts. Every sentence may be vivid; every fact must be
checkable. A reader who follows a link should land on the thing you described.

The test: could someone re-run your commands and get the same numbers? If not, the sentence
is fiction. Cut it or ground it.

## Voice dials

**`tone:sober`** — plain technical prose. Chapter titles may be plain nouns. No metaphor
carries meaning; any image present is decorative and removable without loss. Use for audits,
onboarding packs, and compliance contexts.

**`tone:storyteller`** — the default. Chapter titles are short evocative phrases, sentences
vary in length, and a concrete artifact anchors each section. Light metaphor is fine as long
as it does not replace a fact: "the repository spent July consolidating" is atmosphere;
"the repository spent July consolidating" *plus* the commit count and the paths renamed is
reporting.

**`tone:epic`** — origin-story register, full stop. Still bound by every rule here. Epics fail
when they invent antagonists, defeats, or motivations. The tension available in real history
is usually better than invented drama: a project that was reorganized twice, a module that
was deleted and rewritten, a repository that spent three months on documentation and one
afternoon on 2,880 lines.

## Chapter titles

Good titles are specific enough to be falsifiable.

- Weak: "Early Development" · "The Growth Phase" · "Challenges"
- Strong: "The First Day: 5 Commits and a Rename Sweep" · "July 18th: The Day Everything Was
  Rewritten" · "Four Files That Never Changed" · "The Quiet August"

A title that names a date, a count, or a file is doing work. A title that only gestures is
decoration.

## The cast

Describe contributors as **identities in the log**, with evidence:

- Commit count and share, stated plainly: "14 of 30 commits (47%)".
- Tenure from author dates: first and last commit each appears on.
- Territory: which paths they touched most (`git shortlog -sn HEAD -- <path>`).
- What the log shows they worked on: features, fixes, tests, reviews.

Never do these:

- Invent a personality, role, seniority, or motivation. The log has none of it.
- Rank people. Commit counts measure record-keeping as much as output, and a bot account
  will usually "win" any ranking.
- Infer protected characteristics, employment status, or working hours as productivity.
- Build a single-author repository into a protagonist with an interior life. If one person
  wrote everything, the story is about the project, and the author is a name in it.

Bot and agent accounts get described as what they are: automation that appears in the author
field, with commit counts and the paths they touched. That is genuinely interesting. It is
not a person.

## Reading seasons

- A **burst** is a fact; its cause is a guess. "Seven commits on 2026-07-18, the largest of
  any day" is reportable. "The team crunched for the release" is not, unless a commit
  message, tag, or issue says so.
- A **lull** is reportable as a lull. Do not explain it as holidays, burnout, or a reorg
  without evidence. Say what the gap looks like and what was happening before and after it.
- **Day-of-week and hour** data is texture, not insight, because author dates carry each
  contributor's timezone. One sentence of atmosphere at most, hedged.

## Technical spine

Every chapter should carry at least one real artifact:

- A path, a directory, a module name.
- A commit short SHA you actually opened.
- A command and its output.
- A schema, flag, dependency, or version from the code.

Chapters that are pure atmosphere detach from the repository and become filler. If a
chapter cannot name an artifact, it does not need to exist.

## Turning points

Look for these, then open the commit before writing about it:

- Genesis: the root commit (`git rev-list --max-parents=0 --all`).
- The largest commit by lines changed.
- Renames and reorganizations (`git log -M --diff-filter=R --name-status`).
- Deletions of substantial paths.
- Reversals: the same idea implemented, removed, and implemented again.
- Convention changes: commit prefixes appearing partway through a history.

A turning point is a change in what the repository *is*, not merely a large diff. "Added
2,880 lines" is not a plot point unless you can say what those lines changed about the
project.

## Ghosts

Deleted paths are evidence of abandoned approaches. For each one worth mentioning, name the
deletion commit and describe what the file used to be. "Dead" code, retired experiments,
reverted migrations, and abandoned platform support are all legible in the history.

Do not describe a deleted file's purpose from its path alone unless you read it:
`git show <deletion-sha>^:<path>` still works after the fact.

## Anti-patterns

- Fabricated dialogue, meetings, or conversations.
- "The team realized", "developers were frustrated", "the project struggled" — all
  mind-reading.
- Percentages without denominators ("60% more activity") — always name the window and the base.
- Emoji as a substitute for voice.
- "In today's fast-paced world", "has become increasingly important", or any sentence that
  would survive being pasted into a different repository.
- Turning a file move into a strategic decision.
- Padding: a 30-commit repository does not have six chapters of drama.

## Worked example

Bad:

> The project was born in June 2026, and the team quickly found their rhythm. July was a
> particularly productive month, with the team working late into the night to refine the
> auditing system, which they clearly cared about deeply.

Every claim is invented: "found their rhythm", "working late into the night", "clearly
cared about deeply". The only fact is the month.

Good:

> June 17, 2026: the first commit, `9cf4e34`, lands a skill-audit script with three
> provider integrations — GitHub, GitLab, and Azure DevOps — plus CI examples for GitHub
> Actions and Azure Pipelines, all at the repository root. Three author identities appear
> across the history: two are automation accounts (`GitHub Copilot`, 14 non-merge commits;
> `copilot-swe-agent[bot]`, 7) and one is the maintainer (9), whose work arrives in four
> distinct name-and-email pairs. Activity peaks on 2026-07-18 with 7 commits, including the
> largest single change in the repository at 2,880 lines. August brings two commits, both
> architecture decision records written on the same day by an automation account. By
> September the maintainer is committing directly. No tags were ever created, so there are
> no releases to narrate. `README.md` and `.gitignore` are the only paths that have existed
> since the first commit.

Same facts. The second version is checkable line by line, and it reads like a story because
the facts are specific, not because adjectives were added.

## Derived-note footer

Close the story with a short block so a reader can reproduce it:

```markdown
---
*Derived from: `scripts/repo-stats.sh --scope all` plus targeted `git log`, `git show
--stat`, and `git log -M` queries. Window: full history (2026-06-17 to 2026-09-28).
Scope: all refs. Author dates throughout. Statistics describe recorded history, not
individual effort.*
```

That last sentence matters. It is the difference between a chronicle and a scoreboard.

## Rhythm

Vary sentence length deliberately. Keep paragraphs to three or four sentences. Prefer a
concrete noun to an adjective. Read the draft aloud: if a sentence sounds like it belongs in
a status report, it does.