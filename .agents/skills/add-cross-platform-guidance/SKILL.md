---
name: add-cross-platform-guidance
description: "Install cross-platform development rules into a repository's AGENTS.md by appending a delimited section to an existing file or creating AGENTS.md when none exists, with an optional linked platform guide. Use when a project must support Linux, macOS, and Windows, when agents keep assuming the developer's operating system, or when existing agent instructions need an OS-assumption audit."
---

# Skill: Add Cross-Platform Guidance

Use this skill to make a repository's agent instructions state a platform support contract instead of letting agents infer it from whatever machine they happen to be running on. It appends one delimited section to the applicable `AGENTS.md`, or creates the file when the repository has none, and can link or create a deeper platform guide. It does not review code for portability, change scripts, or edit tooling-specific instruction files.

**Output contract:** a cross-platform section in one `AGENTS.md`, a confirmed platform list, and a report of what was written, linked, created, and deliberately left alone.

---

## Process

### Step 1: Establish the platform contract

Determine which platforms the repository actually claims to support, then have the user confirm that list before any rule text is written. Do not assume the three-platform default and do not assume the current development machine is representative.

Read [platform detection](./references/platform-detection.md) for the evidence sources ranked by strength, the exact detection commands, and the single-OS escape hatch. Load it when the request does not name the target platforms.

Collect evidence in this order, because a manifest is stronger than prose and prose is stronger than assumption:

1. CI matrices and release targets (`runs-on:`, `matrix.os`, per-OS build steps, Electron/PyInstaller/NuGet target lists).
2. Package and project manifests (`os`/`cpu`/`engines` fields, `SupportedOSPlatformVersion`, `TargetFrameworks`, `RuntimeIdentifiers`, trove classifiers).
3. Installers, containers, and CI/CD definitions.
4. README and contributor documentation that state supported systems.
5. The existing `AGENTS.md`, which may already record a contract.

Then report a short table — platform, supporting evidence, confidence — and ask the user to confirm, correct, or trim it. When evidence conflicts (a README claiming three platforms against a CI matrix that builds one), report the conflict and use the stronger evidence rather than averaging them.

If the evidence shows a genuinely single-platform project, then skip Step 4 entirely and use the single-platform variant at the end of the section template in Step 3. Portability rules in a Windows-only desktop app are noise an agent will learn to skip, and the failure is asymmetric: an unnecessary section triggers a cross-platform review on every future change that can only produce false findings.

If nothing in the repository states a platform contract at all, then ask one direct question — which platforms should this project support? — and wait for the answer. Do not infer it from the machine you are running on, and do not default to three platforms without labelling it a default.

**Output:** A confirmed platform list, or a decision to write a single-platform statement instead.

### Step 2: Locate the applicable `AGENTS.md`

Find the instructions file that the target repository's agents actually read. Search tracked files first, then untracked ones if the user asks:

```bash
git ls-files | rg -i '(^|/)(agents|claude)\.md$'
```

Rules for choosing the destination, with the decision criteria stated:

| If | Then |
|---|---|
| Only dot-prefixed instruction files exist (`.claude/`, `.agents/`, `.github/copilot-instructions.md`) | Report them and propose a non-dot-prefixed `AGENTS.md`; never edit a tooling copy |
| A non-dot-prefixed `AGENTS.md` exists | Append to it, following the re-run rules in Step 5 |
| Repository guidance names a different instructions file, and the user confirms it is the source of truth | Write the section there instead of creating a competing `AGENTS.md` |
| Both a root and a nested `AGENTS.md` exist | Ask whether the section belongs at the root, in the scoped file, or in both; never copy root-wide rules into a scoped directory silently |
| No `AGENTS.md` exists anywhere | Propose a root `AGENTS.md` and confirm before creating it |

A nested `AGENTS.md` can narrow or override root guidance, which is why the "both exist" case is a question rather than a default.

Before drafting, record the target file's local conventions so the section matches instead of standing out: heading level and numbering (`## Cross-Platform Development` versus `## 4. Cross-Platform Development`), list marker style (`- item` versus `-   item`), and whether the file ends with an index, table of contents, or footer section that the new section must precede.

**Output:** One confirmed destination file, or a proposal to create a root `AGENTS.md`.

### Step 3: Draft the section

Load [the section template](./references/agents-section-template.md) and adapt it. The template is a starting point, not a fixed string, and its closing single-platform variant applies only when Step 1 concluded the repository is one-platform.

Substitute the placeholders:

| Placeholder | Fill with |
|---|---|
| `{PLATFORMS}` | The confirmed support statement, e.g. "This project supports **Linux, macOS, and Windows**." |
| `{PLATFORM_LIST}` | The per-platform rules that apply to this repository's actual surface. |
| `{GUIDE_PATH}` | A repository-relative link to a platform guide, or the line removed entirely. |

Adaptation rules:

- Keep the section scannable. It states the contract, the rules, and the completion requirement; the twenty-plus topic explanations belong in the guide.
- Keep rules that apply to this repository's stack. A pure-Python library with no installers does not need a Windows-services checklist, and a Node package that already declares `"os": ["darwin"]` needs that fact stated rather than a portability pledge.
- Never invent project facts. No build commands, test commands, or directory names in the section unless they were read out of the repository in Step 1.
- Keep the "do not add another OS-specific workaround" instruction. It is the rule that prevents a portability section from decaying into a pile of per-OS patches.

**Output:** Drafted section text plus the note of which template lines were dropped or reworded.

### Step 4: Resolve the deep guide

The section may link a longer platform guide. Resolve it in exactly one of three ways, and never leave a link pointing at a file that does not exist.

- **If a platform guide already exists** — `docs/development/cross-platform.md`, `docs/cross-platform.md`, `docs/platform-support.md`, or an equivalent — then link to it. Do not duplicate its content, and do not rewrite it. If it contradicts the new section, report the contradiction and ask which one is authoritative.
- **If no guide exists and the user wants one** — then create it from the [platform guide template](./references/platform-guide-template.md) at the repository's conventional path. Default to `docs/development/cross-platform.md`; if `docs/` already uses a different layout, follow that layout and say which path was chosen. Drop topics that do not apply to the detected stack, and keep the final audit checklist.
- **If no guide exists and the user declines** — then remove the link line from the section. A section that stands alone is complete and correct; a section promising a missing document is neither.

**Output:** A confirmed guide path, or an explicit decision that the section stands alone.

### Step 5: Write after confirmation

Show the exact change before writing it: the unified diff for an existing file, or the full proposed file content for a new one. Never write first and describe afterward.

Write behavior:

- **If the file exists** — then append the section at the end by default. If it ends with an index, table of contents, or navigation footer, ask before inserting before it instead.
- **If the file is new** — then create it with a `# AGENTS.md` heading and the cross-platform section only. A new `AGENTS.md` that also asserts build and test commands nobody verified goes stale on the first change.
- **Always** — preserve everything else. Do not reorder, reword, reformat, or renumber existing sections, and do not "tidy" unrelated lines. A guidance edit that touches prose the user did not ask about is a failed run. Match the local style recorded in Step 2, including list marker style, so the diff shows added lines only.

Re-run behavior is part of the write, not an afterthought. Detect an existing cross-platform section before appending, and replace it in place instead:

```bash
rg -n '^#+ .*([Cc]ross-[Pp]latform|portability|platform (support|assumptions))' AGENTS.md
```

If the search matches a heading, then replace that heading and everything up to the next heading of the same or higher level, and show a reconcile diff of the replacement for confirmation rather than silently swapping one rule set for another. If the search matches nothing, then append. If the user wants re-runs to stay unambiguous across heading renames, add an HTML comment marker pair around the section on request; do not add them by default, because they add noise to a file humans also read.

**Output:** The written `AGENTS.md`, plus the guide file if Step 4 created one.

### Step 6: Validate and report

Self-check the write before reporting it. Run the checks in the Validation section, then re-read the section you just wrote and confirm three things against what Step 1 confirmed: the platform list matches word for word, no placeholder survived (`{PLATFORMS}`, `{GUIDE_PATH}`, `{HEADING}`), and no unverified project fact crept in. A guide that exists on disk but is not linked, or a link to a guide that does not exist, is the most common failure here and neither shows up as an error.

Then report: the confirmed platforms and the evidence behind them, the destination file and section heading, whether the guide was linked, created, or skipped, what was deliberately not touched, and any existing portability violations found while gathering evidence.

Report existing violations as a separate finding list. This skill installs rules; it does not fix the code they expose, and silently rewriting scripts in the same run is out of scope.

**Output:** A validation result per checklist item, plus the final report.

---

## Gotchas

- **A second run appends a second section.** Matching only on file existence produces two `## Cross-Platform Development` headings with conflicting rules, and nothing errors — agents read whichever they load first and the file reads as self-contradictory to humans. Always search for the heading first and replace the existing span.
- **Guidance written into a dot-prefixed instruction file disappears from the agent's view.** `.claude/CLAUDE.md`, `.github/copilot-instructions.md`, and `.agents/` files look exactly like project instructions and often already contain a copy of the same rules. Editing one produces two sources of truth with different content. Report them; edit only the non-dot-prefixed `AGENTS.md` the user confirmed.
- **Rules that contradict the repository read as noise.** A strict "never assume Bash" section dropped into a repo full of `#!/bin/bash` scripts gets ignored within days, which is worse than not writing it, because the repo now believes portability is handled. Write the rules anyway, then hand the user a separate violation list with paths.
- **Prettier-style list markers leak into the target file.** The source material this skill derives from uses `-   item` with extra padding. Pasting that into a file written with `- item` produces a diff where every line looks modified. Match the markers already in the file.
- **A promised guide that was never created is a silent failure.** Nothing errors on a relative Markdown link to a missing file, and the breakage surfaces only when an agent follows the link and finds nothing. If the guide is declined, delete the link line in the same edit.
- **Declaring three-platform support for a single-platform project.** A WPF application, a macOS-only release pipeline, or a package pinned to one OS gets a portability pledge it cannot keep, and the section's own completion requirement then fails on every change. Use the single-platform variant routed from Step 1 instead.
- **Filling a new `AGENTS.md` with plausible project facts.** Writing "run `npm test`" into a file created for platform rules produces an unverified command that the user will trust and that will rot. Create the file with the section only.

---

## Validation

After writing, self-check the result and report each item rather than assuming the run succeeded. Substitute the confirmed destination and guide paths for `AGENTS.md` and `docs/development/cross-platform.md`.

```bash
# Whitespace errors and conflict markers
git diff --check

# Exactly one cross-platform heading, in the confirmed file
rg -n '^#+ .*([Cc]ross-[Pp]latform|portability|platform support)' AGENTS.md

# The linked guide exists at the confirmed path
test -f docs/development/cross-platform.md && echo guide-present

# Only the intended file(s) changed
git diff --stat

# No template placeholder survived into the output
rg -n '\{(PLATFORMS|PLATFORM_LIST|GUIDE_PATH|HEADING)\}' AGENTS.md docs/development/cross-platform.md
```

- [ ] `git diff --check` exits 0 and the diff contains no conflict markers.
- [ ] The cross-platform heading appears exactly once in the destination file.
- [ ] Every relative link added by the section resolves to a file that exists.
- [ ] `git diff --stat` shows only the destination `AGENTS.md` and, if created, the guide. No unrelated file is modified.
- [ ] For an existing file, the diff adds or replaces the section only; no pre-existing line was reworded, reordered, or renumbered.
- [ ] For a new file, the file contains the section and nothing that asserts an unverified project fact.
- [ ] The placeholder search returns no matches.
- [ ] The platform list in the section matches the platform list in the guide and the confirmed list from Step 1.
- [ ] Heading level, numbering, and list marker style match the destination file's existing conventions.
- [ ] The final report names the platforms, the file, the heading, the guide decision, and the untouched files.

If the guide path check fails, the section was written with a broken link: remove the link line or create the guide before reporting completion. If `git diff --stat` shows unexpected files, restore them and re-check before continuing. If the placeholder search matches, the section was written from the template without adaptation — re-run Step 3 rather than shipping a file with `{PLATFORMS}` in it.
