# Bash preferences

This document defines the Bash conventions for this project.

The shipped scripts stay intentionally concise. This document is the fuller
reference that explains the design choices, safety rules, and tradeoffs behind
them. When in doubt, follow the current reference implementations:

- `skills/writing-bash-scripts/scripts/pref_bash_script_template.sh`
- `skills/writing-bash-scripts/scripts/run_shellck.sh`

If external Bash advice conflicts with this document or those scripts, prefer
this project's conventions.

## 1. Design goals

These conventions optimize for five things:

- **Safe defaults**: avoid patterns that can unexpectedly delete files, expose
  secrets, or terminate the caller shell.
- **Operational clarity**: make CLI behavior, logging, and exit codes obvious.
- **Readable maintenance**: scripts should be easy to scan and modify without
  jumping through unnecessary abstraction.
- **Source safety**: a file that may be sourced must not silently alter the
  caller shell's options, traps, or control flow.
- **Lintability**: the preferred patterns should pass `shellcheck -x -o all`
  cleanly.

## 2. How to use this reference

- For new scripts, start from
  `skills/writing-bash-scripts/scripts/pref_bash_script_template.sh`.
- For linting, use `skills/writing-bash-scripts/scripts/run_shellck.sh`.
- Keep implementation files lean; put longer rationale in docs like this one.
- Treat the template as the executable example and this document as the
  explanatory guide.

## 3. Naming and file structure

### Function naming

- Use `fct_<descriptive_snake_case>() { ... }` for most project-specific helper
  functions.
- Use plain names for conventional entry points or intentionally public helpers
  when that improves readability. Current examples include `main`, `usage`,
  `show_version`, `cleanup`, `die`, and `log_info` / `log_warn` / `log_error` /
  `log_debug`.
- Use the `name() { ... }` declaration style. Do not use the `function`
  keyword.

```bash
# Preferred
fct_require_command() {
    local cmd="${1}"
    command -v "${cmd}" >/dev/null 2>&1
}

main() {
    :
}

# Avoid
# function RequireCommand { ... }
# helperDoThing() { ... }
```

### File structure

Keep scripts organized in a predictable order. The template's layout is the
default:

1. Metadata and path resolution
2. Runtime options and mutable state
3. Source/execute helpers
4. Logging and error handling
5. Usage and argument parsing
6. Dependency checks
7. Cleanup and traps
8. Main logic and direct-execution guard

This layout matters because Bash scripts are often debugged quickly in a terminal
or CI log. Consistency reduces search time.

## 4. Metadata and path resolution

Define script metadata once and derive the main path variables from
`BASH_SOURCE[0]`.

- Keep `SCRIPT_VERSION`, `SCRIPT_AUTHOR`, and `SCRIPT_DESCRIPTION` near the top.
- Use `SCRIPT_PATH="${BASH_SOURCE[0]}"` rather than `$0` for reliable path
  handling across direct execution and sourcing.
- Derive `SCRIPT_NAME` from `SCRIPT_PATH`.
- Resolve `SCRIPT_DIR` with a quoted `cd` + `pwd -P` pattern instead of relying
  on `realpath`, which is not guaranteed everywhere.

```bash
readonly SCRIPT_PATH="${BASH_SOURCE[0]}"
readonly SCRIPT_NAME="${SCRIPT_PATH##*/}"

fct_get_script_dir() {
    local source="${SCRIPT_PATH}"
    local dir="${source%/*}"

    if [[ "${dir}" == "${source}" ]]; then
        dir="."
    fi

    (cd -- "${dir}" >/dev/null 2>&1 && pwd -P)
}
```

## 5. Variables, quoting, and output

### Constants vs mutable runtime state

- Use `readonly` for constants and metadata.
- Use `UPPERCASE_SNAKE_CASE` for constants and global runtime state.
- Use `local` inside functions whenever possible.
- Use `lowercase_snake_case` for local variables.

Mutable globals are acceptable when cleanup or trap handlers must access them.
Examples include `TMP_DIR`, `TMP_PARENT_DIR`, `LOCK_DIR`, `POSITIONAL_ARGS`, and
`LOG_FILE`.

### Quoting rules

- Quote variable expansions by default: `"${var}"`.
- Quote paths every time, especially when forwarding user input.
- Use braces around variable names to avoid ambiguity.
- Use arrays for collections of arguments; do not build argument lists as raw
  strings.

```bash
# Preferred
printf '%s\n' "${message}"
cp -- "${source_path}" "${dest_dir}/"
TARGETS+=("${path}")

# Avoid
# echo $message
# cp $source_path $dest_dir
# shellcheck $targets
```

### Output functions

- Prefer `printf` over `echo` for predictable behavior.
- Send human-readable logs to stderr.
- Reserve stdout for command results, machine-readable output, `--help`, and
  `--version`.

## 6. Executed vs sourced behavior

This project treats sourced-vs-executed behavior as a first-class safety issue.

- Detect sourcing with `[[ "${BASH_SOURCE[0]}" != "$0" ]]`.
- A sourced file must not auto-run `main`.
- A sourced file must not unconditionally set strict-mode options or install
  traps in the caller shell.
- `main()` should refuse execution when the file is sourced unless the script is
  intentionally designed as a library.

The template follows this pattern:

```bash
IS_SOURCED=0
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    IS_SOURCED=1
fi
readonly IS_SOURCED

fct_exit() {
    local code="${1:-0}"

    if [[ "${IS_SOURCED}" -eq 1 ]]; then
        return "${code}"
    fi
    exit "${code}"
}

if [[ "${IS_SOURCED}" -eq 0 ]]; then
    main "$@"
fi
```

Use `fct_exit()` for helper paths that may run in either mode. That prevents a
library-like use case from unexpectedly killing the parent shell.

## 7. Strict mode and expected failures

### Default mode

Use:

```bash
set -Eeuo pipefail
```

Meaning:

- `-e`: fail fast on unexpected command errors.
- `-E`: make the `ERR` trap inherit into functions and command substitutions.
- `-u`: fail on unset variables to catch typos and missing inputs.
- `-o pipefail`: fail a pipeline when any stage fails, not only the last one.

### When to enable it

- Enable strict mode on the executed path.
- Do not enable it just because the file was sourced.
- It is acceptable to do a small amount of early parsing before enabling strict
  mode if that keeps help/version handling simple and source-safe.

### Expected failures must be explicit

Commands that are allowed to fail must say so clearly in the code.

```bash
# Preferred
if ! command_that_might_fail --option; then
    log_warn "Handled a non-fatal failure."
fi

optional_cleanup || true
```

Do not rely on readers guessing whether a failing command is intentional.

## 8. Logging and fatal errors

### Logging behavior

The standard logging surface is:

- `log_debug`
- `log_info`
- `log_warn`
- `log_error`

Expected behavior:

- include timestamps
- include the script name
- write to stderr
- use color only when stderr is a terminal and `NO_COLOR` is not set
- write plain text, without ANSI escape sequences, to `LOG_FILE`

### Why the template avoids full failed-command logging

The current template logs the failing line number and exit code, not the raw
`${BASH_COMMAND}`. That is intentional. Full command logging can leak secrets in
stderr or persisted log files, especially when failed commands contain tokens,
headers, credentials, or file paths the user did not intend to expose.

This is preferred:

```bash
log_error "Command failed (exit ${exit_status}) at line ${line_no}."
```

This is discouraged by default:

```bash
# Avoid by default
# log_error "Command failed: ${BASH_COMMAND}"
```

### Fatal errors

Use `die()` to log a clear error and exit with a specific status code.

```bash
die() {
    local message="${1:-Unknown error}"
    local exit_code="${2:-1}"

    log_error "${message}"
    fct_exit "${exit_code}"
}
```

Prefer actionable messages when possible, especially for missing dependencies or
invalid user input.

## 9. Log-file safety

If a script supports `--log-file`, validate the target before writing to it.

Required checks:

- reject an empty path
- reject symlinks
- reject non-regular existing targets
- reject missing parent directories
- fail cleanly when the file cannot be created or appended to
- create new files with restrictive permissions when practical

Why this matters:

- symlinks can redirect writes to unintended locations
- devices, FIFOs, or special files can corrupt output or block the script
- loose permissions can expose logs that contain sensitive operational data

## 10. Argument parsing

### Preferred approach

Use explicit manual parsing when the CLI includes long options such as
`--no-color` or `--log-file`. Use `getopts` when the interface is simple and
short-option-only.

This project does not require `getopts` everywhere. Clarity matters more than
blind adherence to one parser style.

### Minimum expectations

The template supports these options:

- `-h`, `--help`
- `-V`, `--version`
- `-v`, `--verbose`
- `--no-color`
- `--log-file PATH`
- `--`

### Parsing rules

- Emit clear errors for unknown options.
- Validate option arguments before using them.
- Preserve remaining positionals in an array.
- Honor `--` to stop option parsing.
- Keep usage output readable and synchronized with real behavior.

```bash
--)
    shift
    POSITIONAL_ARGS+=("$@")
    break
    ;;
```

If an option needs special validation, centralize that validation in one helper
instead of spreading it across multiple branches.

## 11. Dependencies and portability

### Dependency checks

Fail early when required tools are missing.

```bash
fct_require_command() {
    local cmd="${1}"
    local hint="${2:-}"

    if ! command -v "${cmd}" >/dev/null 2>&1; then
        if [[ -n "${hint}" ]]; then
            die "Missing required command: ${cmd}. ${hint}" 4
        fi
        die "Missing required command: ${cmd}." 4
    fi
}
```

Give installation hints when the dependency is common and the action is obvious.

### Portability expectations

- Scripts are Bash-specific, not POSIX `sh`.
- Keep macOS/Linux compatibility in mind.
- Prefer Bash builtins and simple external tools over unnecessary dependencies.
- Be careful with GNU-only flags and non-portable utilities.
- Use `command -v` instead of `which`.

## 12. Temporary files, cleanup, traps, and signals

This is one of the most important safety sections in the project.

### Temporary files and directories

- Use `mktemp` / `mktemp -d`.
- Keep temp paths in dedicated variables.
- Track the temp parent directory when cleanup safety depends on it.
- Never `rm -rf` a path that was not validated first.

### Cleanup rules

Cleanup must not mask the real exit status.

Preferred pattern:

```bash
cleanup() {
    set +e

    if [[ -n "${LOCK_DIR}" && -d "${LOCK_DIR}" ]]; then
        rmdir -- "${LOCK_DIR}" 2>/dev/null || true
    fi

    if [[ -n "${TMP_DIR}" && -e "${TMP_DIR}" ]]; then
        :
    fi
}

fct_run_cleanup_on_exit() {
    local exit_status=$?

    trap - EXIT ERR
    cleanup
    exit "${exit_status}"
}
```

Important details:

- clear traps before cleanup if recursion or duplicate logging is possible
- preserve the original exit status
- make cleanup tolerant of partially initialized state
- use `--` with destructive commands when a path could begin with `-`

### Safe deletion

If cleanup removes a temp directory, bound the deletion to a path you created.
The current template validates that the resolved temp path:

- is absolute
- still exists
- is not a symlink
- resolves under the expected temp parent
- matches the script's temp-dir naming pattern

This is the correct mindset for `rm -rf`: narrow the allowed target, then delete.
Do not write cleanup like this:

```bash
# Avoid
# trap 'rm -rf "${temp_dir}"' EXIT
```

That pattern is short, but it hides too much trust in the variable's value.

### Signals and ERR traps

- Install `INT` and `TERM` handlers when a script owns temporary resources.
- Use an `ERR` trap for centralized logging on unexpected failures.
- Keep signal handlers simple: log, choose the right exit code, and exit.
- Avoid trap bodies that do too much work or depend on complicated shell state.

## 13. Safe Bash defaults

This section collects the smaller language-level defaults that still matter in
day-to-day scripts.

### Command substitution

Use `$(...)`, not backticks.

```bash
local current_date
current_date="$(date +%Y-%m-%d)"
```

### Tests and pattern matching

Prefer `[[ ... ]]` over `[ ... ]` for string comparisons, file checks, and
regex/pattern matching.

```bash
if [[ -f "${file_path}" && "${user_name}" == "admin" ]]; then
    :
fi
```

### Arithmetic

Use `(( ... ))` for arithmetic.

```bash
local counter=0
((counter++))
if (( counter > 10 )); then
    :
fi
```

### Loops and `read`

Use `read -r` and control `IFS` deliberately.

```bash
while IFS= read -r line || [[ -n "${line}" ]]; do
    printf '%s\n' "${line}"
done < "input.txt"
```

For null-delimited file lists:

```bash
find . -type f -print0 | while IFS= read -r -d '' file_path; do
    printf '%s\n' "${file_path}"
done
```

### IFS changes

If you must change `IFS`, localize it and restore it quickly. Do not quietly
alter shell-wide splitting behavior for the rest of the function or script.

## 14. Idempotency and file operations

Prefer operations that can be run repeatedly without causing drift or damage.

Examples:

```bash
mkdir -p "${target_dir}"

if ! grep -qFx "${setting_line}" "${config_file}"; then
    printf '%s\n' "${setting_line}" >> "${config_file}"
fi
```

Additional file-operation guidance:

- be explicit about overwrite behavior
- quote all paths
- use `--` where option-like filenames are possible
- avoid broad globs in destructive commands
- prefer appending to arrays over building command strings

## 15. Comments and readability

Scripts in this project should be concise, but not cryptic.

- Use comments to explain **why**, assumptions, or non-obvious safety behavior.
- Do not comment every obvious line.
- Keep section headers short and useful.
- Prefer simple control flow over clever compactness.

Good candidates for comments:

- why strict mode is enabled in a specific location
- why a path is considered safe to delete
- why a trap clears other traps before cleanup
- why a sourced file refuses to run `main()`

## 16. ShellCheck workflow

Use the wrapper:

```bash
# Default: scan the wrapper's own scripts directory
skills/writing-bash-scripts/scripts/run_shellck.sh

# Specific files or directories
skills/writing-bash-scripts/scripts/run_shellck.sh path/to/script.sh
skills/writing-bash-scripts/scripts/run_shellck.sh skills/writing-bash-scripts/scripts other/dir/
```

The wrapper intentionally does three useful things:

- detects shell files by extension (`.sh`, `.bash`, `.zsh`, `.command`) or by
  shebang
- normalizes leading-dash paths before passing them to shell tools
- runs `shellcheck -x -o all -- ...`

Use `shellcheck` as part of normal development, not only as a final check.
Warnings often point to exactly the sort of quoting, trap, and control-flow bugs
that are hardest to notice in Bash reviews.

For shipped scripts in this skill, the standard is zero `shellcheck` findings.

## 17. Final rule of thumb

If a Bash script can be made shorter by removing a safety boundary, that is
usually the wrong simplification.

In this project, the preferred result is:

- lean executable scripts
- comprehensive documentation
- explicit cleanup and error behavior
- predictable logging and exit codes
- lint-clean Bash
