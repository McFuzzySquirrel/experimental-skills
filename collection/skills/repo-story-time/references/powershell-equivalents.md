# PowerShell Equivalents

> Load when: the session runs on Windows, in PowerShell, or on a host where `sh`, `awk`,
> or GNU `date` is unavailable.

The skill is written for POSIX shell because that is where `git` is least surprising. On
Windows you have three options, in order of preference:

1. **Run the digest in Git Bash or WSL** and keep the whole skill unchanged. This is the
   recommended path.
2. **Translate the commands** using the table below. Every row is a direct equivalent.
3. **Skip the script** and gather the numbers with `git log` piped through PowerShell
   cmdlets, accepting more manual work.

`git` itself is identical everywhere. Everything that differs is the shell around it.

## The digest script

```powershell
# If Git Bash is on PATH, run the POSIX script unchanged.
bash ./scripts/repo-stats.sh --scope all --top 20

# Otherwise, approximate the totals in PowerShell:
git rev-list --all --count
git rev-list --count HEAD
git rev-list --first-parent --count HEAD
git rev-list --is-shallow-repository
git log --no-merges --format=%H | Measure-Object -Line
git shortlog -sn --no-merges HEAD
```

The script's `awk` sections have no one-line PowerShell equivalent. Run it under Git Bash
or WSL rather than reimplementing it.

## Command translation

| Purpose | POSIX | PowerShell |
|---|---|---|
| Count commits | `git rev-list --count HEAD` | `git rev-list --count HEAD` |
| Count lines of output | `git log --oneline \| wc -l` | `(git log --oneline \| Measure-Object -Line).Lines` |
| Top N by count | `... \| sort \| uniq -c \| sort -rn \| head -20` | `... \| Group-Object \| Sort-Object Count -Descending \| Select-Object -First 20 Count, Name` |
| First N lines | `... \| head -5` | `... \| Select-Object -First 5` |
| Last N lines | `... \| tail -5` | `... \| Select-Object -Last 5` |
| Trim blanks | `sed '/^$/d'` | `Where-Object { $_ -ne '' }` |
| Exclude by pattern | `grep -vE 'node_modules'` | `Where-Object { $_ -notmatch 'node_modules' }` |
| Count matches | `grep -c pattern` | `(git log --format=%H \| Select-String -Pattern pattern \| Measure-Object).Count` |
| Substring | `cut -c1-7` | `$_.Substring(0, 7)` |
| Field split | `awk -F'\t' '{print $2}'` | `ForEach-Object { ($_ -split "`t")[1] }` |
| Month buckets | `--date=format:'%Y-%m'` | `--date=format:'%Y-%m'` |
| Regex alternation in grep | `grep -E 'a\|b'` (quotes matter) | `Select-String -Pattern 'a\|b'` |
| Show file tree | `find . -type d` | `Get-ChildItem -Recurse -Directory` |
| Directory listing | `ls -la` | `Get-ChildItem -Force` |
| Env var | `$HOME` | `$env:USERPROFILE` |

## Regex traps in PowerShell

`git log --grep` still needs `-E`; the shell does not change git's regex engine:

```powershell
# Wrong: matches nothing, because git uses POSIX BRE and "|" is literal.
git log --oneline --grep="feat|fix|update"

# Right:
git log --oneline -E --grep="feat|fix|update"
```

In PowerShell, `-` inside a double-quoted string is fine, but `$` is not: use single
quotes for git format strings that contain `$`, or escape it as `` `$ ``.

## Notes

- `git log --date=format:'%Y-%m'` needs no change; the format string belongs to git.
- `Get-ChildItem -Recurse` is slow on large trees. Prefer `git ls-files` when the
  repository is tracked, and exclude `.git` explicitly otherwise.
- Exit codes are the same: `2` for a non-repository, `3` for a shallow clone.
- If `--out` is used from PowerShell, pass a Windows path; `mkdir -p` inside the script
  becomes a no-op failure that the script already tolerates.