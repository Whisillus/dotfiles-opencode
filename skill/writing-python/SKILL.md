---
name: writing-python
description: Use this when creating, modifying, debugging, or testing Python code or scripts. Follow the repository's existing Python toolchain and conventions first; only introduce new tooling when the project has no clear setup or the user explicitly asks.
---

# Python

Use this skill whenever the user asks to create, update, refactor, debug, or test Python code.

## Core Rules

- Match the repository's existing toolchain, layout, dependency manager, test style, and typing strictness before introducing new patterns.
- Do not install Python versions, global tools, or new dependencies unless the repo already requires them or the user explicitly asks.
- Prefer project-local execution over host-global changes.
- Make the smallest correct change. Avoid repo-wide refactors, config churn, or mass formatting unless the task calls for it.
- Prefer inlining simple one-off logic over extracting tiny helper functions; create a function only when it improves clarity, reuse, testing, or side-effect isolation.
- Never commit secrets. Prefer existing environment variables or a secret manager; use a local untracked `.env` file only for local development when needed.
- Add `timeout=` to `subprocess.run(...)` in tests and helper scripts that execute commands.
- Avoid `shell=True` unless shell semantics are required or the existing code already depends on it.

## Toolchain Selection

Choose commands in this order:

1. Read the repo's README, docs, CI, Makefile, task runner, and nearby scripts.
2. `uv.lock`, `uv` docs, or existing `uv run ...` commands -> use `uv`.
3. `poetry.lock` or `[tool.poetry]` -> use `poetry`.
4. `Pipfile` -> use `pipenv`.
5. `requirements.txt`, `pyproject.toml`, `tox.ini`, `noxfile.py`, or an existing virtualenv -> follow those.
6. No clear toolchain -> keep changes minimal, use the existing interpreter or virtualenv, and avoid introducing a new package manager by default.

Examples below use bare commands such as `pytest`. If the repo uses a runner, prefix the command with that runner:

```bash
uv run pytest
poetry run pytest
pipenv run pytest
pytest
```

## Existing-Project Workflow

1. Read Python config, docs, and nearby code before editing.
2. Match naming, imports, exceptions, type hints, logging, and test style already used in the repo.
3. Implement the smallest change that solves the task.
4. Add or update tests as close as practical to the changed behavior.
5. Run targeted checks first, then broader project checks if needed.
6. If a tool reports unrelated failures, avoid broad cleanup unless the user asks.

## New Code Defaults

### Modules and Libraries

- Keep core logic in small, testable functions; isolate filesystem, network, and subprocess side effects at the edges.
- Prefer the standard library first; add dependencies only when they clearly simplify the task and fit the project.
- Use `pathlib.Path` instead of string path manipulation.
- Use explicit `encoding="utf-8"` for text files unless the project requires another encoding.
- Add type hints for public functions, return values, and non-trivial data flow.
- Raise specific exceptions in library code; let callers decide how to present errors.
- Use `logging` for diagnostic output in libraries or long-running scripts; use `print()` for user-facing CLI output.
- Add docstrings for public APIs or non-obvious behavior; keep them factual and short.

### Scripts and CLIs

- Use `argparse` by default unless the repo already uses `click`, `typer`, or another CLI framework.
- Prefer a `main()` function that returns an integer exit code.
- Write normal output to stdout and error messages to stderr.
- Add `--dry-run` when a script mutates files, systems, or remote state.
- Validate input early and fail with clear, actionable messages.
- Keep parsing, business logic, and side effects in separate functions when possible.

Canonical CLI pattern:

```python
import argparse
import sys


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Describe the script clearly")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show actions without changing anything",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        if args.dry_run:
            print("Would perform work")
            return 0

        print("Work complete")
        return 0
    except ValueError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 2
    except (OSError, RuntimeError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
```

Common exit code pattern for scripts when the repo does not define one:

- `0` - success
- `1` - runtime or external system error
- `2` - validation or usage error

## Testing Strategy

- Test pure functions directly before reaching for subprocess tests.
- Use subprocess tests for CLI parsing, exit codes, environment handling, stdout/stderr, or end-to-end script behavior.
- Use fixtures such as `tmp_path`, `monkeypatch`, and deterministic test data to isolate state.
- Do not hit real networks, external services, or destructive system resources by default; mock or stub them.
- Keep tests deterministic: fixed inputs, explicit environment setup, and timeouts on spawned commands.

Direct-call tests are usually the best default:

```python
def test_slugify_basic_case() -> None:
    assert slugify("Hello, World!") == "hello-world"
```

Subprocess tests are appropriate when the CLI wrapper itself is part of the behavior under test.

## Subprocess and External Commands

- Build commands as lists, not shell strings, unless shell behavior is required.
- Pass `cwd=` and `env=` explicitly when context matters.
- Use `capture_output=True`, `text=True`, and `timeout=` for test helpers.
- Use `check=False` when you want to assert on exit codes; use `check=True` only when failure should raise immediately.
- Prefer `sys.executable` when invoking Python from the current environment.

## Verification Order

1. Run the narrowest relevant test or command first.
2. Run file- or package-scoped lint and type checks before project-wide checks.
3. Use non-mutating commands before `--fix` or formatting.
4. Expand to broader verification only as needed or when the repo expects it.
5. Do not relax lint or type settings just to make one change pass.

## Common Pitfalls

- Mutable default arguments such as `def add(item, items=[]): ...`
- Bare `except:` clauses
- Comparing with `== None` instead of `is None`
- Hiding side effects inside utility functions that look pure
- Broad reformatting or import cleanup unrelated to the task
- Adding new tooling when the repo already has a Python workflow

## Bundled Resources

- `references/ruff.md` - Linting and formatting guidance
- `references/pyright.md` - Static type checking guidance
- `references/pytest.md` - Testing guidance
