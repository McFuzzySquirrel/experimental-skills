# Platform Guide Template

> Load in Step 4 of `add-cross-platform-guidance` when the user has approved creating a deep platform guide because the repository does not already have one.

Write the guide to a repository-relative path, defaulting to `docs/development/cross-platform.md`. This template is the starting point, not the output: substitute the placeholders, drop topics that do not apply to the repository's stack, and keep the closing audit checklist intact.

## Placeholders

| Placeholder | Replace with |
|---|---|
| `{PLATFORMS}` | The confirmed platform list from Step 1, matching the `AGENTS.md` section exactly |
| `{GUIDE_TITLE}` | A title matching the repository's doc conventions |

## How To Adapt

- **Substitute `{PLATFORMS}` everywhere it appears.** A guide that names Linux, macOS, and Windows while the section promises two platforms is a contradiction the user will have to resolve later.
- **Drop topics that cannot apply.** A pure library with no installer does not need the installers topic. A project with no container workflow does not need the containers topic. Dropping is better than keeping a section that says "not applicable" in the repository's own documentation.
- **Keep the core principle section.** The distinction between "make it platform-neutral" and "add a branch for the other OS" is the reason the guide exists, and it is what prevents the rules below it from decaying into per-OS patches.
- **Keep the audit checklist at the end.** It is the only part a reader can run mechanically.
- **Do not add project facts.** No commands, paths, or package names unless they were read out of the repository.
- **Match the destination's documentation style** if the repository has a convention for docs under `docs/`.

## Template

````markdown
# {GUIDE_TITLE}

## Purpose

{PLATFORMS}

The developer's machine is not necessarily representative of the
machines on which the software will be installed or executed.

The goal is therefore not merely to make code "work on my machine", but
to eliminate accidental platform assumptions from the implementation.

---

## 1. The core principle

> **The developer's operating system is an implementation detail, not a
> project requirement.**

When encountering an OS-specific failure, do not immediately add a
workaround for the other operating system.

First ask:

1.  Why is this operation platform-specific?
2.  Is there a platform-neutral API?
3.  Can the OS-specific behaviour be isolated behind an abstraction?
4.  Is the platform dependency actually required?

Prefer:

``` text
application/runtime API
        ↓
platform abstraction
        ↓
OS
```

over:

``` text
application
        ↓
shell command
        ↓
OS-specific behaviour
```

---

## 2. Filesystem and paths

### Avoid hard-coded paths

Do not assume:

``` text
/tmp
/home/user
/usr/local
~/something
C:\Users\user
C:\Program Files
```

Use the runtime's platform-aware APIs for:

-   temporary directories
-   home directories
-   application data
-   cache directories
-   configuration directories
-   executable locations
-   path joining
-   path normalization

### Treat paths as opaque

Paths may contain:

-   spaces
-   Unicode
-   apostrophes
-   parentheses
-   brackets
-   shell metacharacters
-   non-ASCII characters

Do not manually concatenate paths with `/` or `\` when a path API is
available.

### Case sensitivity

Do not assume:

``` text
src/Foo.ts
src/foo.ts
```

refer to the same file.

Code should behave correctly on case-sensitive filesystems even if
development normally occurs on a case-insensitive filesystem.

### Reserved filenames

Windows has reserved names including:

``` text
CON
PRN
AUX
NUL
COM1
LPT1
```

Generated files and directories must not accidentally use these names.

### Drive letters and UNC paths

Do not assume paths begin at `/`.

Windows may use:

``` text
C:\...
\\server\share\...
```

Path handling must use platform-aware APIs.

---

## 3. Shells and command execution

### Never assume Bash

These are different environments:

-   Bash
-   Zsh
-   PowerShell
-   Windows Command Prompt
-   other POSIX-compatible shells

Do not put shell syntax into cross-platform configuration unless the
shell is explicitly part of the contract.

### Avoid unnecessary shell commands

Prefer:

``` text
filesystem API
process API
archive API
HTTP API
JSON API
```

over invoking:

``` text
mkdir
rm
cp
mv
grep
sed
awk
cat
find
chmod
which
```

Many Unix utilities are unavailable or behave differently on Windows.

### Process execution

Prefer:

``` text
executable + argument array
```

over:

``` text
shell command string
```

This improves:

-   quoting
-   escaping
-   spaces in paths
-   security
-   portability

Avoid constructing commands like:

``` text
"tool " + path + " --output " + output
```

when the runtime supports structured arguments.

---

## 4. Environment variables

Do not embed shell-specific environment-variable syntax in application
logic.

Examples that are not universally portable:

``` text
$HOME
${HOME}
%USERPROFILE%
$env:USERPROFILE
```

Use the runtime's environment-variable API.

Also avoid assuming variables such as:

``` text
HOME
USER
USERPROFILE
PATH
SHELL
PWD
TMPDIR
```

have the same meaning or are always present.

---

## 5. Temporary files and directories

Never assume:

``` text
/tmp
```

is the temporary directory.

Use the runtime/OS temporary-directory API.

Also consider:

-   cleanup
-   concurrent execution
-   filename collisions
-   permissions
-   locked files
-   antivirus/file-indexing interference on some platforms

---

## 6. File permissions

Unix executable permissions do not map directly to Windows.

Avoid assuming:

``` text
chmod +x script
```

is sufficient to make something executable everywhere.

Where possible, invoke scripts through their runtime rather than relying
on executable bits.

For example, conceptually:

``` text
node script.js
```

is more portable than assuming:

``` text
./script.js
```

will execute.

---

## 7. Symlinks

Do not assume symbolic links can be:

-   created
-   resolved
-   modified
-   committed
-   used by every user

Windows permissions and configuration can affect symlink creation.

Prefer copying or explicit configuration when a symlink is not
essential.

---

## 8. Line endings

Support:

``` text
LF
CRLF
```

Do not write tests that fail merely because a file uses different line
endings.

Be careful when:

-   generating scripts
-   generating configuration
-   comparing files
-   parsing text
-   generating snapshots
-   committing generated files

---

## 9. Encoding

Use explicit encoding when reading and writing files where the runtime
permits it.

Do not assume terminal encoding or locale behaviour.

Test paths and content containing Unicode.

---

## 10. Process management

Do not assume Unix signal semantics.

Differences may occur around:

-   SIGTERM
-   SIGINT
-   SIGKILL
-   Ctrl+C
-   child processes
-   process groups
-   process trees
-   graceful shutdown

If the application starts child processes, explicitly consider:

1.  How are they started?
2.  How are they monitored?
3.  How are they stopped?
4.  What happens if the parent crashes?
5.  Does shutdown work on Windows?

---

## 11. Networking

Do not assume:

-   IPv4 only
-   IPv6 only
-   localhost resolves identically everywhere
-   a port is available
-   binding semantics are identical
-   firewall rules are absent

Avoid tests that require a particular network interface or IP address.

Prefer:

``` text
127.0.0.1 / ::1 handling where appropriate
dynamic test ports
explicit host configuration
```

---

## 12. Locale, timezone and dates

Tests must not depend on the developer's:

-   locale
-   timezone
-   date format
-   decimal separator
-   language

Avoid parsing human-readable command output.

Prefer machine-readable formats such as:

``` text
JSON
ISO 8601
structured API responses
```

Where time matters, explicitly define whether the value is:

-   UTC
-   local time
-   an offset-aware timestamp

---

## 13. Terminal behaviour

Do not assume:

-   ANSI colour support
-   Unicode rendering
-   terminal width
-   cursor control
-   interactive input
-   clipboard availability

CLI applications should degrade gracefully when no interactive terminal
is available.

---

## 14. Opening files and applications

Commands such as these are platform-specific:

``` text
open
xdg-open
start
```

Use a platform abstraction where an application needs to open:

-   a browser
-   a file
-   a directory
-   another application

---

## 15. Architecture

Support may involve:

``` text
x64 / amd64
ARM64 / aarch64
```

Native dependencies must be checked for architecture compatibility.

Do not assume the architecture of the developer's machine is the
architecture of the target environment.

This is especially important for:

-   native Node modules
-   compiled .NET components
-   Python native packages
-   database drivers
-   embedded runtimes
-   Docker images
-   downloadable binaries

---

## 16. Native dependencies

Before adding a dependency, determine whether it requires:

-   a compiler
-   system headers
-   SDKs
-   native libraries
-   platform-specific binaries
-   Python
-   Visual Studio Build Tools
-   Xcode Command Line Tools
-   GCC/Clang
-   system packages

Prefer dependencies that provide supported binaries for all target
platforms when practical.

---

## 17. Package managers

Do not assume:

``` text
npm
pnpm
yarn
brew
apt
dnf
pacman
winget
choco
```

are available unless the project explicitly requires one.

Project setup documentation should clearly identify:

-   required runtime
-   required package manager
-   supported versions
-   platform-specific prerequisites

---

## 18. Git

Consider:

-   CRLF/LF conversion
-   case sensitivity
-   executable bits
-   symlinks
-   filename restrictions
-   generated files
-   ignored files

A repository that works on Linux can still contain Git/file-layout
assumptions that fail on Windows.

---

## 19. Containers

Do not assume container volume mounts behave identically across
platforms.

Pay particular attention to:

-   host path syntax
-   file permissions
-   UID/GID mapping
-   filesystem performance
-   case sensitivity
-   bind mounts
-   Docker Desktop versus native Linux Docker
-   Windows/WSL interoperability

---

## 20. Installers and setup

A cross-platform installation experience should consider:

### Linux

-   shell availability
-   distribution differences
-   package manager differences
-   permissions
-   system services

### macOS

-   Intel versus Apple Silicon
-   Gatekeeper
-   permissions
-   Homebrew location
-   launchd

### Windows

-   PowerShell versus cmd
-   `.exe` / `.cmd` / `.ps1`
-   Program Files
-   AppData
-   PATH modification
-   Windows services
-   Defender/antivirus interaction
-   long/path and filename restrictions

Do not silently modify system-wide configuration when a user-scoped
option is sufficient.

---

## 21. Testing strategy

At minimum, distinguish:

### Portable unit tests

Must not depend on OS-specific behaviour.

### Platform-specific tests

Explicitly validate behaviour that genuinely differs between operating
systems.

### Integration tests

Exercise:

-   process creation
-   filesystem operations
-   installation
-   configuration
-   networking
-   native dependencies

### CI matrix

Where practical, validate every platform in the support contract
({PLATFORMS}) and the relevant architectures.

---

## 22. Cross-platform audit checklist

Before declaring work complete:

### Filesystem

-   [ ] No hard-coded OS paths
-   [ ] No manual path separator assumptions
-   [ ] No case-sensitivity assumptions
-   [ ] No reserved Windows filenames
-   [ ] No drive-letter assumptions
-   [ ] No symlink assumptions
-   [ ] No executable-bit assumptions
-   [ ] Temporary directories use platform APIs

### Shell

-   [ ] No accidental Bash dependency
-   [ ] No accidental PowerShell dependency
-   [ ] No unnecessary Unix utilities
-   [ ] No shell command string construction where structured process
    APIs exist
-   [ ] Arguments are safely quoted/escaped

### Environment

-   [ ] Environment variables use runtime APIs
-   [ ] No assumed home directory
-   [ ] No assumed config directory
-   [ ] No assumed PATH layout
-   [ ] No assumed username

### Runtime

-   [ ] Process handling is portable
-   [ ] Shutdown behaviour is portable
-   [ ] Networking does not assume a specific interface
-   [ ] Locale is not assumed
-   [ ] Timezone is not assumed
-   [ ] Terminal capabilities are not assumed

### Dependencies

-   [ ] Runtime versions are documented
-   [ ] Native dependencies are identified
-   [ ] CPU architecture is considered
-   [ ] Required external tools are documented

### Installation

-   [ ] Clean installation has been considered
-   [ ] Upgrade works
-   [ ] Uninstall/cleanup works
-   [ ] Platform-specific configuration is isolated

### Testing

-   [ ] Tests are OS-independent where possible
-   [ ] Platform-specific behaviour has explicit tests
-   [ ] CI covers the supported operating systems
````

## Before Writing The File

- [ ] `{PLATFORMS}` is substituted in every occurrence.
- [ ] The guide's platform list is identical to the section's platform list.
- [ ] Topics that cannot apply to the repository's stack are dropped, not padded.
- [ ] The core principle section and the audit checklist are both present.
- [ ] No project facts were invented.
- [ ] The path matches the repository's `docs/` convention, or the user approved the default.
- [ ] The `AGENTS.md` section link points at exactly this path.
