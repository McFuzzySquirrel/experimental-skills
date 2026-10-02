# Git Recipes

> Load when: a phase needs a query the `repo-stats.sh` digest does not produce, when you
> are adapting the digest, or when a digest row needs corroborating evidence.

All commands are POSIX shell and plain `git`. Run them from anywhere with `-C <path>`, or
from the repository root. Placeholders are `<angle-bracketed>`.

Every recipe below is verified against real repositories. Where a naive version of a query
fails silently, the failure and the fix are both noted.

## Orientation

```bash
git rev-parse --show-toplevel                 # repository root
git rev-parse --is-inside-work-tree           # exit 0 when you are in a repository
git rev-parse --is-shallow-repository         # "true" means incomplete history
git symbolic-ref --short -q HEAD              # current branch; empty when detached
git remote get-url origin                     # may be absent; quote it cautiously
git ls-files | wc -l                          # tracked path count
git ls-files | grep -cE '(^|/)\.'            # dot-prefixed (tooling) paths
```

State the root and the scope in the documents. A narrative about the wrong checkout is
worse than no narrative.

## Scope: which history you are telling

```bash
git rev-list --all --count                    # every reachable ref
git rev-list --count HEAD                     # current branch only
git rev-list --first-parent --count HEAD      # trunk only, merges collapsed
```

These three routinely disagree. Pick one, say which, and use it consistently. `--all`
includes topic and remote branches that may be abandoned; `--first-parent` hides the side
work that makes a project interesting.

## Totals and windows

```bash
git rev-list --count HEAD
git rev-list --count --since=12.months HEAD
git rev-list --count --until=2026-01-01 HEAD
git log --merges --format=%H | wc -l           # merge commits
git log --no-merges --format=%H | wc -l        # direct commits
git tag | wc -l                               # release markers; zero means no release arc
```

A repository with no tags can still have a story, but you may not invent version numbers.

## People

```bash
git shortlog -sn --no-merges HEAD                  # commit counts by author
git shortlog -sn --no-merges --all                 # across every ref
git shortlog -sn -e --no-merges HEAD               # with emails (opt in only)
git shortlog -sn HEAD -- <path>                    # who worked on one area
git log --format='%aN <%aE>' | sort | uniq -c | sort -rn   # distinct identities
git log --format='%an%x09%ad' --date=short | sort   # author names over time
```

`%aN` is the `.mailmap`-aware name, `%an` is the raw one. Prefer `%aN`.

```bash
git log --format='%(trailers:key=Co-authored-by,valueonly)' | sort | uniq -c
```

Co-author trailers credit humans working alongside automation. Bots and agent accounts
appear in the author field on their own and must be described as log identities, not as
colleagues with motives.

```bash
git log --format='%aN' | sort -u | wc -l           # how many distinct author names
git log --format='%aN <%aE>' | sort -u             # watch for one human, many identities
```

A single person with four names is a data-quality finding worth mentioning in the story.

## Time

```bash
git log --date=format:'%Y-%m' --format='%ad' | sort | uniq -c | sort -k2   # by month
git log --date=format:'%u'   --format='%ad' | sort | uniq -c              # 1=Mon .. 7=Sun
git log --date=format:'%H'   --format='%ad' | sort | uniq -c | sort -rn   # hour of day
git log --date=short --format='%ad' | sort | uniq -c | sort -rn | head    # busiest days
git log --reverse --format='%ad %h %s' --date=short | head -n 1          # genesis
git log -1 --format='%ad %h %s' --date=short                             # most recent
```

`%ad` is the author date (when the work was written); `%cd` is the committer date (when it
landed). Buckets near midnight move between them. Declare the basis you used.

Author times are in each contributor's local timezone. An "11pm burst" may be one person's
morning; treat hour-of-day data as texture, never as a conclusion.

## Themes and commit vocabulary

```bash
# Naive and silently broken: git log uses POSIX BRE, so "|" is a literal character.
git log --oneline --grep="feat|fix|update" | wc -l        # returns 0, and looks plausible

# Correct: extended regular expression.
git log --oneline -E --grep="feat|fix|update"
git log --oneline -E --grep='^fix(\(|:)'                  # anchored to the subject
git log --oneline -E --grep='#[0-9]+'                     # issue references
```

This is the single most common silent failure in repository archaeology. In the repository
measured while writing this skill, `--grep="feat|fix|update"` returned 0 commits and
`-E --grep="feat|fix|update"` returned 15. If a themed query returns nothing, test the empty
case before believing it.

```bash
git log --format='%s' | awk '{split(tolower($0),w,/[^a-z]+/); print w[1]}' \
  | sort | uniq -c | sort -rn | head                     # subject prefixes, no regex engine
git log --format='%s' | awk '{t+=length($0); n++} END {print t/n}'   # mean subject length
```

A long mean subject length usually means careful messages. A very short one usually means
a team that relies on the diff.

## Files

```bash
# Hot files, with generated and lockfile noise removed.
git log --no-merges --name-only --format= | sed '/^$/d' \
  | grep -vE '(^|/)(node_modules|dist|build|vendor|out|coverage)/|\.(lock|map|min\.[a-z]+)$|(^|/)(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Cargo\.lock|poetry\.lock|composer\.lock|go\.sum)$' \
  | sort | uniq -c | sort -rn | head -20

# Layout census: two path segments, root files handled.
git ls-files | awk -F/ 'NF>1 {print $1"/"$2} NF==1 {print "(root) "$1}' | sort | uniq -c | sort -rn

# File type mix.
git ls-files | awk -F. 'NF>1 {print tolower($NF)} NF==1 {print "(none)"}' | sort | uniq -c | sort -rn

# Introduced and retired.
git log --diff-filter=A --name-only --format= | sed '/^$/d' | sort -u
git log --diff-filter=D --name-only --format= | sed '/^$/d' | sort -u
```

```bash
git ls-tree -r --name-only "$(git rev-list --max-parents=0 HEAD | tail -n 1)" | sort > /tmp/born
git ls-files | sort > /tmp/now
comm -12 /tmp/born /tmp/now                                          # survivors since genesis
```

## Renames, moves, and rewrites

```bash
git log -M --diff-filter=R --name-status --format='%h %s'    # renames with similarity score
git log --follow --oneline -- <path>                         # history across a rename
git log --oneline -- <path> | wc -l                           # how long a file has existed
```

Without `-M`, a reorganization looks like a mass deletion plus a mass creation. With
`--follow`, a moved file keeps its history, which is usually the difference between
"this project was reorganized" and "this project lost everything in July".

## Deep dives

```bash
git show --stat <sha>                       # what one commit actually changed
git show --stat --format=fuller <sha>       # with author and dates
git log -p -- <path>                        # full patch history for one path
git log -S '<string>' --oneline             # when a literal appeared or vanished
git log -G '<regex>' --oneline              # when a pattern changed
git blame -L 1,20 --date=short -- <path>    # who last touched specific lines
git show <sha>^:<path>                      # a file as it was before a commit
```

Use `git log -S` to date the moment a decision entered the code: a magic number, a
framework name, or a flag that did not exist before some commit.

## Landmarks

```bash
git log --no-merges --format='COMMIT %h %ad %s' --date=short --numstat \
  | awk '/^COMMIT /{if(s)printf "%8d %s\n",t,l; s=$2; l=$0; sub(/^COMMIT [^ ]+ [^ ]+ /,"",l); t=0; next}
         $1!="-"&&NF==3{t+=$1+$2} END{if(s)printf "%8d %s\n",t,l}' \
  | sort -rn | head -10                     # largest commits by lines changed

git rev-list --max-parents=0 --all          # root commits: one means an imported history
git for-each-ref --sort=-creatordate --format='%(refname:short) %(creatordate:short)' refs/tags
git for-each-ref --format='%(refname:short)' refs/heads refs/remotes
```

More than one root commit across all refs usually means several imported or grafted
histories. One root commit plus one enormous commit means a squashed import: narrate the
code's age carefully, because the log cannot see it.

## Corroboration checklist

Before a claim reaches the story, confirm it:

1. The number appears in a command you ran in this session.
2. A representative commit behind it has been opened with `git show --stat`.
3. The scope that produced it is stated.
4. Nothing in it identifies a person beyond what the log records.