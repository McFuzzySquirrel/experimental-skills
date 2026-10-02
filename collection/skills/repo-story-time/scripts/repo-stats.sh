#!/bin/sh
# repo-stats.sh - emit a plain-text digest of a repository's structure and history.
#
# Part of the repo-story-time skill. Produces the evidence layer that the
# narrative is later written from. It reports facts only: no interpretation.
#
# Usage: see --help. No dependencies beyond git and POSIX sh. No network access.
# Writes nothing except the optional --out file. Never mutates the repository.

set -u

PROG="repo-stats.sh"
REPO="."
SINCE=""
SCOPE="head"
WITH_EMAILS=0
OUT=""
TOP=20

EXIT_NOT_A_REPO=2
EXIT_SHALLOW=3

usage() {
	cat <<EOF
$PROG - repository history digest for the repo-story-time skill

Usage: $PROG [options]

Options:
  --repo PATH        Repository to inspect (default: current directory)
  --since DATE       Only include commits after DATE, e.g. 12.months, 2026-01-01
  --scope SCOPE      Which history to report: head (default), all, first-parent
  --with-emails      Include author emails (off by default to avoid leaking PII)
  --out FILE         Also write the digest to FILE (it is always printed to stdout)
  --top N            How many rows per ranked list (default: $TOP)
  -h, --help         Show this help

Exit codes:
  0  Digest produced
  2  Not a Git repository
  3  Digest produced, but the history is shallow (see the WINDOW section)

Notes:
  - Digest rows are a starting index, not a story. Open the diffs behind any
    number you plan to narrate: git show --stat <sha>.
  - Author names use .mailmap-aware %aN. Bot and agent identities appear as
    ordinary authors; do not invent personhood for them.
  - Dates come from %ad (author date). Switch to %cd (committer date) if the
    narrative depends on when work landed rather than when it was written.
EOF
}

while [ $# -gt 0 ]; do
	case "$1" in
	--repo)
		REPO="${2:-}"
		shift 2 || exit 2
		;;
	--repo=*)
		REPO="${1#--repo=}"
		shift
		;;
	--since)
		SINCE="${2:-}"
		shift 2 || exit 2
		;;
	--since=*)
		SINCE="${1#--since=}"
		shift
		;;
	--scope)
		SCOPE="${2:-}"
		shift 2 || exit 2
		;;
	--scope=*)
		SCOPE="${1#--scope=}"
		shift
		;;
	--with-emails)
		WITH_EMAILS=1
		shift
		;;
	--out)
		OUT="${2:-}"
		shift 2 || exit 2
		;;
	--out=*)
		OUT="${1#--out=}"
		shift
		;;
	--top)
		TOP="${2:-20}"
		shift 2 || exit 2
		;;
	--top=*)
		TOP="${1#--top=}"
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		printf '%s: unknown option: %s\n' "$PROG" "$1" >&2
		usage >&2
		exit 2
		;;
	esac
done

case "$SCOPE" in
head | all | first-parent) ;;
*)
	printf '%s: --scope must be head, all, or first-parent (got: %s)\n' "$PROG" "$SCOPE" >&2
	exit 2
	;;
esac

if ! git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1; then
	printf '%s: not a Git repository: %s\n' "$PROG" "$REPO" >&2
	printf 'Fall back to a filesystem inventory and say in the story that\n' >&2
	printf 'Git history could not be used.\n' >&2
	exit "$EXIT_NOT_A_REPO"
fi

ROOT="$(git -C "$REPO" rev-parse --show-toplevel 2>/dev/null)"
[ -n "$ROOT" ] || ROOT="$REPO"

case "$SCOPE" in
head) SCOPE_ARG="HEAD" ;;
all) SCOPE_ARG="--all" ;;
first-parent) SCOPE_ARG="HEAD" ;;
esac

if [ "$WITH_EMAILS" -eq 1 ]; then
	AUTHOR="%aN <%aE>"
else
	AUTHOR="%aN"
fi

git_log() {
	if [ -n "$SINCE" ]; then
		git -C "$ROOT" log --since="$SINCE" "$@"
	else
		git -C "$ROOT" log "$@"
	fi
}

git_log_scope() {
	if [ "$SCOPE" = "first-parent" ]; then
		if [ -n "$SINCE" ]; then
			git -C "$ROOT" log --first-parent --since="$SINCE" "$@"
		else
			git -C "$ROOT" log --first-parent "$@"
		fi
	else
		git_log "$SCOPE_ARG" "$@"
	fi
}

total_commits() {
	git_log_scope --format=%H 2>/dev/null | wc -l | tr -d ' '
}

emit_repo() {
	printf '\n== REPO ==\n'
	printf 'root              %s\n' "$ROOT"
	printf 'scope             %s\n' "$SCOPE"
	printf 'since             %s\n' "${SINCE:-<all history>}"
	printf 'branch            %s\n' "$(git -C "$ROOT" symbolic-ref --short -q HEAD 2>/dev/null || echo 'detached')"
	printf 'origin            %s\n' "$(git -C "$ROOT" remote get-url origin 2>/dev/null || echo '<none>')"
	printf 'tracked files     %s\n' "$(git -C "$ROOT" ls-files | wc -l | tr -d ' ')"
	printf 'shallow           %s\n' "$(git -C "$ROOT" rev-parse --is-shallow-repository 2>/dev/null || echo unknown)"
	printf 'authors with email %s\n' "$([ "$WITH_EMAILS" -eq 1 ] && echo yes || echo no)"
}

emit_window() {
	printf '\n== WINDOW ==\n'
	local_first="$(git_log_scope --reverse --date=short --format='%ad' 2>/dev/null | head -n 1)"
	local_last="$(git_log_scope --date=short --format='%ad' 2>/dev/null | head -n 1)"
	printf 'first commit      %s\n' "${local_first:-<none>}"
	printf 'last commit       %s\n' "${local_last:-<none>}"
	printf 'commits in scope  %s\n' "$(total_commits)"
	if [ -n "$local_first" ] && [ -n "$local_last" ]; then
		span="unknown (non-GNU date)"
		if first_epoch="$(date -u -d "$local_first" +%s 2>/dev/null)" &&
			last_epoch="$(date -u -d "$local_last" +%s 2>/dev/null)"; then
			span="$(( (last_epoch - first_epoch) / 86400 ))"
		fi
		printf 'span (days)       %s\n' "$span"
	fi
	if [ "$(git -C "$ROOT" rev-parse --is-shallow-repository 2>/dev/null)" = "true" ]; then
		printf 'WARNING           history is shallow; seasons and cast are incomplete\n'
	fi
	if [ "$(total_commits)" -lt 5 ]; then
		printf 'WARNING           very little history; keep the narrative modest\n'
	fi
}

emit_totals() {
	printf '\n== TOTALS ==\n'
	printf '%-26s %s\n' 'commits (--all)' "$(git -C "$ROOT" rev-list --all --count 2>/dev/null || echo '?')"
	printf '%-26s %s\n' 'commits (HEAD)' "$(git -C "$ROOT" rev-list --count HEAD 2>/dev/null || echo '?')"
	printf '%-26s %s\n' 'commits (--first-parent)' "$(git -C "$ROOT" rev-list --first-parent --count HEAD 2>/dev/null || echo '?')"
	printf '%-26s %s\n' 'merges' "$(git_log_scope --merges --format=%H | wc -l | tr -d ' ')"
	printf '%-26s %s\n' 'non-merge commits' "$(git_log_scope --no-merges --format=%H | wc -l | tr -d ' ')"
	printf '%-26s %s\n' 'tags' "$(git -C "$ROOT" tag | wc -l | tr -d ' ')"
	printf '%-26s %s\n' 'local branches' "$(git -C "$ROOT" for-each-ref --format='%(refname:short)' refs/heads | wc -l | tr -d ' ')"
	printf '%-26s %s\n' 'remote branches' "$(git -C "$ROOT" for-each-ref --format='%(refname:short)' refs/remotes | wc -l | tr -d ' ')"
	printf '%-26s %s\n' 'paths ever deleted' "$(git_log_scope --no-merges --diff-filter=D --name-only --format= | sed '/^$/d' | sort -u | wc -l | tr -d ' ')"
}

emit_contributors() {
	printf '\n== CONTRIBUTORS ==\n'
	git_log_scope --no-merges --format="$AUTHOR" | sort | uniq -c | sort -rn | head -n "$TOP" |
		awk '{ $1 = $1; printf "  %5s  %s\n", $1, substr($0, index($0, $2)) }'
	printf '\n-- tenure (author dates, --no-merges) --\n'
	git_log_scope --no-merges --date=short --format="$AUTHOR%x09%ad" |
		awk -F'\t' '
			{
				name = $1; day = $2
				if (day == "") next
				if (!(name in lo) || day < lo[name]) lo[name] = day
				if (!(name in hi) || day > hi[name]) hi[name] = day
			}
			END {
				for (name in lo) printf "  %-32s %s .. %s\n", name, lo[name], hi[name]
			}'
}

emit_monthly() {
	printf '\n== MONTHLY (author date, --no-merges) ==\n'
	git_log_scope --no-merges --date=format:'%Y-%m' --format='%ad' | sort | uniq -c | sort -k2 |
		awk '{ printf "  %-8s %5s\n", $2, $1 }'
}

emit_weekday() {
	printf '\n== WEEKDAY (1=Mon .. 7=Sun) ==\n'
	git_log_scope --no-merges --date=format:'%u' --format='%ad' | sort | uniq -c |
		awk '{ printf "  day %-3s %5s\n", $2, $1 }'
}

emit_hours() {
	printf '\n== HOURS OF DAY (top %s, author date) ==\n' "$TOP"
	git_log_scope --no-merges --date=format:'%H' --format='%ad' | sort | uniq -c | sort -rn | head -n "$TOP" |
		awk '{ printf "  %-6s %5s\n", $2, $1 }'
}

emit_commit_types() {
	printf '\n== COMMIT SUBJECT PREFIXES ==\n'
	git_log_scope --no-merges --format='%s' |
		awk '
			{
				lower = tolower($0)
				split(lower, w, /[^a-z]+/)
				p = w[1]
				if (p ~ /^(feat|fix|docs|refactor|test|chore|build|ci|perf|style|revert|release|hotfix|upgrade|wip)$/) {
					count[p]++
				} else {
					count["(other)"]++
				}
			}
			END { for (k in count) printf "  %-12s %5s\n", k, count[k] }' | sort -k2 -rn
	printf '\n-- conventional commits matched with -E (grep is BRE without it) --\n'
	for kind in feat fix docs refactor test chore ci perf; do
		count="$(git_log_scope --no-merges -E --grep="^$kind(\(|:)" --format=%H | wc -l | tr -d ' ')"
		[ "$count" -gt 0 ] && printf '  %-12s %5s\n' "$kind" "$count"
	done
}

emit_hot_files() {
	printf '\n== HOT FILES (commit touches, generated/lock noise filtered) ==\n'
	printf '  noise filter: node_modules, dist, build, vendor, lockfiles, *.min.*, source maps\n'
	git_log_scope --no-merges --name-only --format= | sed '/^$/d' |
		grep -vE '(^|/)(node_modules|dist|build|vendor|out|coverage)/|\.(lock|map|min\.[a-z]+)$|(^|/)(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Cargo\.lock|poetry\.lock|composer\.lock|go\.sum)$' |
		sort | uniq -c | sort -rn | head -n "$TOP" |
		awk '{ printf "  %5s  %s\n", $1, $2 }'
	printf '\n-- filtered-out path hits (noise) --\n'
	printf '  %5s\n' "$(git_log_scope --no-merges --name-only --format= | sed '/^$/d' |
		grep -cE '(^|/)(node_modules|dist|build|vendor|out|coverage)/|\.(lock|map|min\.[a-z]+)$|(^|/)(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Cargo\.lock|poetry\.lock|composer\.lock|go\.sum)$')"
}

emit_churn() {
	printf '\n== CHURN ==\n'
	printf -- '-- largest commits by lines changed --\n'
	git_log_scope --no-merges --format='COMMIT %h %ad %s' --date=short --numstat |
		awk '
			/^COMMIT / {
				if (sha != "") printf "  %8s  %s %s  %s\n", total, sha, day, subject
				sha = $2; day = $3
				subject = $0
				sub(/^COMMIT [^ ]+ [^ ]+ /, "", subject)
				total = 0
				next
			}
			$1 != "-" && NF == 3 { total += $1 + $2 }
			END { if (sha != "") printf "  %8s  %s %s  %s\n", total, sha, day, subject }' |
		sort -rn | head -n "$TOP"
	printf '\n-- files introduced (first appearance) --\n'
	git_log_scope --no-merges --diff-filter=A --name-only --format= | sed '/^$/d' | sort -u | head -n "$TOP"
	printf '\n-- files retired (deleted paths) --\n'
	git_log_scope --no-merges --diff-filter=D --name-only --format= | sed '/^$/d' | sort -u | head -n "$TOP"
}

emit_shape() {
	printf '\n== SHAPE ==\n'
	printf -- '-- merges (top %s) --\n' "$TOP"
	git_log_scope --merges --date=short --format='  %ad %h %s' | head -n "$TOP"
	printf '\n-- longest-lived files still tracked (present in the first commit) --\n'
	first_sha="$(git_log_scope --reverse --format='%H' | head -n 1)"
	if [ -n "$first_sha" ]; then
		born="$(mktemp 2>/dev/null)"
		now="$(mktemp 2>/dev/null)"
		git -C "$ROOT" ls-tree -r --name-only "$first_sha" | sort >"$born"
		git -C "$ROOT" ls-files | sort >"$now"
		comm -12 "$born" "$now" | head -n "$TOP" | sed 's/^/  /'
		rm -f "$born" "$now"
	else
		printf '  <no commits>\n'
	fi
	printf '\n-- branches --\n'
	git -C "$ROOT" for-each-ref --format='  %(refname:short) %(committerdate:short)' refs/heads refs/remotes | head -n "$TOP"
}

emit_file_mix() {
	printf '\n== FILE MIX (tracked paths by extension) ==\n'
	git -C "$ROOT" ls-files |
		awk '
			{
				n = split($0, parts, "/")
				base = parts[n]
				if (base ~ /^\./ || base !~ /\./) { ext = "(none)" }
				else { ext = base; sub(/^.*\./, ".", ext); ext = tolower(ext) }
				count[ext]++
			}
			END { for (e in count) printf "%d\t%s\n", count[e], e }' |
		sort -rn | head -n "$TOP" | awk '{ printf "  %5s  %s\n", $1, $2 }'
}

emit_landmarks() {
	printf '\n== LANDMARKS ==\n'
	printf -- '-- genesis --\n'
	git_log_scope --reverse --date=short --format='  %ad %h %an  %s' 2>/dev/null | head -n 1
	printf -- '-- most recent --\n'
	git_log_scope --date=short --format='  %ad %h %an  %s' 2>/dev/null | head -n 1
	printf -- '-- busiest day --\n'
	git_log_scope --no-merges --date=short --format='%ad' | sort | uniq -c | sort -rn | head -n 5 |
		awk '{ printf "  %-10s %5s commits\n", $2, $1 }'
	printf -- '-- newest tag --\n'
	newest_tag="$(git -C "$ROOT" for-each-ref --sort=-creatordate --format='%(refname:short) %(creatordate:short)' refs/tags | head -n 1)"
	printf '  %s\n' "${newest_tag:-<no tags: do not invent a release arc>}"
	printf -- '-- mean subject length (charter) --\n'
	git_log_scope --no-merges --format='%s' | awk '{ total += length($0); n++ } END { if (n > 0) printf "  %.1f chars across %d commits\n", total / n, n; else print "  <no commits>" }'
}

main() {
	emit_repo
	emit_window
	if [ "$(total_commits)" -eq 0 ]; then
		printf '\n== NOTE ==\n'
		printf 'No commits reachable in this scope. Report an empty history rather\n'
		printf 'than inventing one.\n'
		return 0
	fi
	emit_totals
	emit_contributors
	emit_monthly
	emit_weekday
	emit_hours
	emit_commit_types
	emit_hot_files
	emit_churn
	emit_shape
	emit_file_mix
	emit_landmarks
	printf '\n== END ==\n'
	printf 'Evidence layer only. Corroborate headline numbers with git show --stat <sha>.\n'
}

if [ -n "$OUT" ]; then
	tmp="$(mktemp 2>/dev/null || echo "/tmp/repo-stats.$$")"
	main >"$tmp"
	mkdir -p "$(dirname "$OUT")" 2>/dev/null
	if ! cp "$tmp" "$OUT"; then
		printf '%s: could not write %s\n' "$PROG" "$OUT" >&2
		cat "$tmp"
		rm -f "$tmp"
		exit 2
	fi
	printf '%s: digest also written to %s\n' "$PROG" "$OUT" >&2
	cat "$tmp"
	rm -f "$tmp"
else
	main
fi

[ "$(git -C "$ROOT" rev-parse --is-shallow-repository 2>/dev/null)" = "true" ] && exit "$EXIT_SHALLOW"
exit 0