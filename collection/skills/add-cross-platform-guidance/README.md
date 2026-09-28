# add-cross-platform-guidance

Install cross-platform development rules into a target repository's `AGENTS.md` so agents stop inferring the platform contract from whatever machine they happen to be running on.

The skill appends one delimited section to the applicable instructions file, or creates `AGENTS.md` when the repository has none, and can link or create a deeper platform guide. It installs rules; it does not review code for portability, change scripts, or edit tooling-specific instruction files.

## When To Use It

Use this skill for requests such as:

- "Add cross-platform guidance to this repo."
- "Our agents keep assuming Linux."
- "Document our platform support contract in AGENTS.md."
- "Audit the agent instructions for OS assumptions."

## Installation

Copy the complete skill directory into the skill location used by your assistant:

```bash
cp -r collection/skills/add-cross-platform-guidance .agents/skills/
```

Keep the directory name `add-cross-platform-guidance` unchanged. The package is self-contained and includes its `SKILL.md` and `references/` files.

## Workflow

The skill:

1. Establishes the platform contract from ranked evidence and gets the user to confirm it before any rule text is written.
2. Locates the applicable `AGENTS.md`, asking rather than guessing when a nested file or an alternative instructions file is in play.
3. Drafts the section from the template, adapting it to the destination file's heading level, numbering, and list-marker style.
4. Resolves the deep platform guide in one of three ways: link an existing guide, create one, or drop the link line.
5. Shows the exact diff before writing, and replaces an existing cross-platform section in place instead of appending a second one.
6. Validates the result against a checklist and reports the platforms, the file, the heading, the guide decision, and what was left untouched.

Evidence is ranked by strength: CI matrices and release targets first, then package and project manifests, installers and packaging config, containers and dev environment, README and contributor prose, and the existing `AGENTS.md`. A manifest is stronger than prose, and prose is stronger than assumption. When sources conflict, the skill reports the conflict and follows the stronger source rather than averaging.

| If the evidence shows | Then |
|----------------------|------|
| Multiple platforms with consistent support | Write the multi-platform section |
| A genuinely single-platform project | Write the single-platform variant: state the target and tell agents not to add portability abstraction |
| Nothing at all | Ask which platforms the project should support, and never infer it from the current machine |

## Scope Boundaries

- The section goes in the non-dot-prefixed `AGENTS.md` the user confirmed. `.claude/CLAUDE.md`, `.github/copilot-instructions.md`, and `.agents/` files are reported, never edited.
- Existing prose is preserved. A guidance run that rewords, reorders, or renumbers unrelated lines has failed.
- A new `AGENTS.md` is created with the cross-platform section only. Adding plausible build or test commands produces unverified facts that rot.
- Existing portability violations found while gathering evidence are reported as a separate finding list with paths. Fixing them is out of scope.
- The section is a contract, not a portability pledge. A single-OS project gets the single-platform variant, because an unnecessary portability section triggers cross-platform reviews that can only produce false findings.

## Supporting References

- [`references/platform-detection.md`](references/platform-detection.md): evidence sources ranked by strength, detection commands, conflict resolution, and the single-OS escape hatch.
- [`references/agents-section-template.md`](references/agents-section-template.md): the `AGENTS.md` section template, placeholder mapping, adaptation rules, placement rules, and the single-platform variant.
- [`references/platform-guide-template.md`](references/platform-guide-template.md): the 22-topic guide used when the repository has no existing guide to link, plus adaptation and pre-write checks.

## Validation

After the skill writes, run its self-check against the confirmed destination and guide paths:

```bash
# Whitespace errors and conflict markers
git diff --check

# Exactly one cross-platform heading
rg -n '^#+ .*([Cc]ross-[Pp]latform|portability|platform support)' AGENTS.md

# The linked guide exists at the confirmed path
test -f docs/development/cross-platform.md && echo guide-present

# Only the intended file(s) changed
git diff --stat

# No template placeholder survived into the output
rg -n '\{(PLATFORMS|PLATFORM_LIST|GUIDE_PATH|HEADING)\}' AGENTS.md docs/development/cross-platform.md
```

The most common silent failure is a section promising a guide that does not exist, or a guide that exists on disk but is never linked. Neither errors; the breakage only surfaces when an agent follows the link.

When local and packaged copies of this skill both exist, follow the repository's documented source-of-truth rule and keep the copies synchronized when changing the workflow.
