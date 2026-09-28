# AGENTS.md Cross-Platform Section Template

> Load when drafting or editing the cross-platform section of a target repository's `AGENTS.md`, in Step 3 of `add-cross-platform-guidance`.

Adapt the template below. Delete rules that do not apply to the repository's stack, keep the ones that do, and never paste it unedited: an unmodified copy of this template is the fastest way to produce a section that contradicts the project it was installed into.

## Placeholders

| Placeholder | Replace with | If unresolved |
|---|---|---|
| `{PLATFORMS}` | Confirmed support statement, e.g. `**Linux, macOS, and Windows**` | Stop and ask. Never guess. |
| `{PLATFORM_LIST}` | Per-platform rules for the repository's actual surface | Keep the generic rules only |
| `{GUIDE_PATH}` | Repository-relative link to a platform guide | Delete the whole link block |
| `{HEADING}` | `## Cross-Platform Development`, or the destination file's numbered or alternative style | Use the style recorded in Step 2 |

## Section Template

```markdown
{HEADING}

{PLATFORMS}

Agents MUST treat the developer's current operating system as an
implementation detail, not as an assumption about the target
environment.

The detailed requirements are documented in:

-   [{Platform Guide Title}]({GUIDE_PATH})

### Core rules

-   Never assume the project is running on any one supported operating
    system unless the task explicitly requires it.
-   Never hard-code OS-specific filesystem paths.
-   Prefer platform-neutral runtime/library APIs over shell commands.
-   Never assume Bash or Unix utilities are available.
-   Never construct shell commands when an executable-plus-arguments API
    can be used instead.
-   Treat paths as opaque values and assume they may contain spaces,
    Unicode, parentheses, apostrophes, or other special characters.
-   Do not rely on Unix executable permission bits.
-   Do not assume LF line endings.
-   Do not assume case-insensitive filesystems.
-   Do not assume symlink support.
-   Do not assume Unix process signals or process-tree behaviour.
-   Do not assume a particular home directory, temporary directory,
    config directory, username, drive letter, or executable extension.
-   Do not assume a particular CPU architecture.
-   Do not assume development tools or Unix utilities are installed
    unless they are declared project prerequisites.
-   Tests MUST NOT depend on the developer's OS, shell, locale,
    timezone, username, home directory, or filesystem layout.

{PLATFORM_LIST}

### Scripts and automation

When a script is required:

1.  Prefer a cross-platform language/runtime over shell-specific
    scripting.
2.  If shell scripting is unavoidable, explicitly document the supported
    shell and provide platform-specific alternatives where necessary.
3.  Avoid embedding platform-specific path or environment-variable
    syntax in shared configuration.
4.  Quote/escape arguments safely.
5.  Handle spaces and special characters in paths.
6.  Fail with a useful message when a required external dependency is
    unavailable.

### Installation and execution

Installation, setup, build, test, start, stop, update, and cleanup
workflows must be reviewed for:

-   OS differences
-   CPU architecture
-   filesystem semantics
-   permissions
-   shell behaviour
-   environment variables
-   native dependencies
-   executable naming
-   process management
-   line endings
-   configuration locations

### Completion requirement

Before declaring work complete, perform a cross-platform compatibility
review of any new or changed:

-   scripts
-   installers
-   build configuration
-   process management
-   filesystem operations
-   environment/configuration handling
-   native dependencies
-   developer tooling
-   CI/CD automation

**Important:** Do not fix a portability failure merely by adding another
OS-specific workaround. First determine whether the underlying
implementation can be made platform-neutral.
```

## Adaptation Rules

- **Style must match the destination file.** The template above uses `-   item` list markers and hard-wrapped prose. Most files use `- item` and long lines; match what is already in the target so the diff shows added lines rather than every line changed.
- **Drop rules that cannot apply.** A pure library with no installer does not need the installation list. A repository that declares `"os": ["darwin", "linux"]` in its manifest should say so explicitly and drop the universal-pledge framing.
- **Keep the completion requirement.** It is the only part of the section that makes the rules self-enforcing, and it is the part most often dropped for length. Shorten it rather than deleting it.
- **Keep the final "Important" note.** Without it, agents respond to a portability failure by adding the next OS-specific branch, and the section decays into a stack of patches.
- **Do not add project facts.** No build commands, test commands, package names, or directory names unless they were read out of the repository.
- **Do not reference the skill.** The installed section must read as project guidance, not as generated output. No "generated by" comments, no skill names, no placeholder text.

## Single-Platform Variant

Use this only when Step 1 of `SKILL.md` has concluded the repository is genuinely single-platform. It is reached from the skill, not from another reference, so the evidence for that conclusion stays in Step 1.

```markdown
{HEADING}

This project targets **{PLATFORMS}** only. It is not portable, and
portability is not a goal.

-   Agents MUST assume {PLATFORMS} unless the task says otherwise.
-   Do not add cross-platform abstraction, multi-OS branches, or
    platform-neutral shims to this project.
-   Document the requirement here rather than letting agents infer it
    from the build environment.
-   When {PLATFORMS}-specific behaviour is used, say so in the code
    comment or the pull request description.
```

## Placement Rules

- Append after the last existing section unless the file ends with an index, table of contents, or navigation footer; in that case ask before inserting before it.
- If the destination already has a cross-platform, portability, or platform-support section, replace that section in place rather than appending a second one. Show the reconcile diff first.
- Keep the section self-contained. It should be actionable if the guide link is followed by nothing, which is why the guide link is optional.
