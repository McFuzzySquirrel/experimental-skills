# Platform Detection

> Load in Step 1 of `add-cross-platform-guidance` when the request does not name the target platforms, and again in Step 3 when the repository may be single-platform.

The goal is a platform list backed by evidence the user can check, not a default that happens to be right. A portability section is a promise about what the project supports; an unverified promise makes every later completion review fail.

## Evidence Sources, Strongest First

| Source | What to look for | Strength |
|---|---|---|
| CI matrices and release workflows | `runs-on:`, `matrix.os`, `strategy.matrix`, per-OS build/publish steps, Electron `--mac`/`--win` targets, PyInstaller OS flags, NuGet `RuntimeIdentifiers` | Strongest — it is what actually gets built |
| Package and project manifests | `os`, `cpu`, `engines` in `package.json`; `SupportedOSPlatformVersion` and `TargetFrameworks` in `.csproj`; `classifiers` in `pyproject.toml`/`setup.py`; `[target]` tables in `Cargo.toml` | Strong — an explicit contract |
| Installers and packaging config | `.nsi`, WiX, `electron-builder` targets, `pkg`, `dotnet publish -r`, Homebrew formula, Chocolatey manifest, MSI/AppImage configs | Strong |
| Containers and dev environment | `Dockerfile` base images, `docker-compose.yml`, `devcontainer.json` image | Medium — dev shell, not support contract |
| README and contributor docs | "Requirements", "Supported platforms", install instructions per OS | Medium — can be aspirational |
| Existing `AGENTS.md` | A stated platform contract, or an absence of one | Medium — may be wrong |
| Package registry metadata | `engines`, `os` fields on the published package | Medium — only reflects the published artifact |
| Nothing found | — | Weak — say so and ask |

## Detection Commands

Run the first command always, then pick the ones that match the repository's stack. `rg` is used here as a plain search; fall back to `grep -r` where `rg` is unavailable.

```bash
# What the repository is (pick the relevant one)
git ls-files | rg -i '\.(csproj|sln|fsproj|pyproject\.toml|setup\.py|Cargo\.toml|go\.mod|pom\.xml|build\.gradle|pubspec\.yaml|composer\.json|package\.json)$'

# CI and release target platforms
rg -n 'runs-on|matrix:|os:\s*\[|target:|--mac|--win|win32|darwin|linux' .github .gitlab-ci.yml azure-pipelines.yml .circleci 2>/dev/null

# Declared platform constraints in manifests
rg -n '"os"|"cpu"|"engines"|SupportedOSPlatformVersion|TargetFramework|RuntimeIdentifier|OperatingSystem' --glob '!**/node_modules/**' .

# Prose claims
rg -ni 'supported (platforms|operating systems|os)|linux, macos|macos, windows|windows, linux|requirements' --glob '*.md'

# Existing guidance, including tooling copies that must not be edited
git ls-files | rg -i '(^|/)(agents|claude)\.md$'
```

Two cautions on these commands. A `Dockerfile` running `FROM node:20` proves the dev shell is Linux, not that the project is Linux-only — a Linux container is how most cross-platform projects run on macOS and Windows. And `git ls-files` omits untracked files, so a new `.github/workflows` in progress will not appear; say so rather than reporting a clean result.

## Confirm Before Writing

Report the findings as a table and get explicit confirmation before drafting rule text:

```
Platform   Evidence                                            Confidence
Linux      ubuntu-latest in CI matrix; linux-arm64 release     High
macOS      macos-latest in CI matrix; --mac publish step       High
Windows    windows-latest in CI matrix; NSIS installer         High
```

Then ask the user to confirm, correct, or trim the list. Record the confirmed list verbatim; the section, the guide, and the final report must all use it.

**Default when the user does not respond with a correction:** the detected list. Do not fall back to "Linux, macOS, and Windows" because that is the common case, and do not fall back to the current machine.

## Conflicting Evidence

Report the conflict, pick the stronger source, and say which one you picked and why. Do not average the two and do not silently take the majority of mentions.

| Conflict | Resolution |
|---|---|
| README says three platforms, CI builds one | CI wins, and the README is flagged as stale documentation |
| CI builds three, no platform is documented anywhere | Report the three, note the documentation gap |
| `package.json` has `"os": ["linux"]`, CI builds three | Manifest wins for the published package; flag CI as over-building or the manifest as stale |
| `SupportedOSPlatformVersion` present, no CI for Windows | Treat Windows as intended-but-unvalidated; write the rules, flag the missing validation |
| Contributor docs and README disagree | Both are prose; ask the user rather than guessing |

## Single-OS Escape Hatch

When the repository is genuinely one-platform, stop and return to Step 1 of `SKILL.md`, which routes a single-platform conclusion to the single-platform variant. Signals:

- A manifest pins the platform: `"os": ["darwin"]`, `SupportedOSPlatform` with no `Version`, a `.plist`-only desktop target, a Microsoft Store or WPF/WinUI project.
- CI builds and publishes for exactly one OS, and the README documents installation for that OS only.
- A system-level tool that cannot run elsewhere: a macOS menu-bar utility, a Windows service host, a Linux-only daemon.
- The user's request is about documenting a decision that was already made ("we only ship Windows").

Then state the single-platform contract instead of promising portability. The single-platform variant exists because the failure is asymmetric: an unnecessary portability section is noise the team learns to ignore, and it triggers a cross-platform review on every future change that can only ever produce false findings.

Ask before switching to the single-platform variant. A repository with one CI job today may be three platforms next quarter, and a one-line contract is easy to replace with the full section later; a portability pledge on a single-OS project is harder to walk back because code will start depending on the promise.

## When Nothing Is Found

No platform evidence anywhere means the repository has no stated contract. That is the most common case for a new project, and it is a legitimate reason to ask one direct question: which platforms should this project support?

Do not infer the answer from the machine you are running on. Do not default to three platforms without saying it is a default and asking for confirmation.
