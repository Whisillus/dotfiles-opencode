---
name: write-python
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
- Do not create private helper functions just to organize one or two lines. Inline single-use logic unless a helper names a non-obvious concept, is reused, improves tests, or isolates side effects.
- Before adding helper logic, search nearby modules and shared utility packages for existing functions, constants, classes, or domain abstractions that already express the operation. Reuse project utilities instead of duplicating formulas or reimplementing behavior inline.
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
3. Search for existing helpers/utilities before adding new logic, especially for math, path handling, parsing, serialization, validation, retries, and domain conventions.
4. Implement the smallest change that solves the task.
5. Add or update tests as close as practical to the changed behavior.
6. Run targeted checks first, then broader project checks if needed.
7. If a tool reports unrelated failures, avoid broad cleanup unless the user asks.

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

- Do not introduce `argparse`, `click`, `typer`, or another CLI parser unless the user asks for command-line options, the existing file is already a CLI, or the task explicitly requires user-facing argument parsing.
- Preserve the existing invocation style. For small scripts, prefer constants, direct function parameters, or the existing `main()` shape over adding a parser.
- Prefer a `main()` function that returns an integer exit code.
- Write normal output to stdout and error messages to stderr.
- Add `--dry-run` when a script mutates files, systems, or remote state.
- Validate input early and fail with clear, actionable messages.
- Separate parsing, business logic, and side effects only when the code is large enough that separation improves clarity, reuse, or tests. For small scripts, keep straightforward one-off logic inline.
- Before finalizing, review every new `_private_helper`. Inline it when it is single-use and simpler than its call site.

Minimal script shape when a file needs executable entry-point behavior:

```python
import sys


def main() -> int:
    try:
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
- Creating one-line or single-use `_private_helper()` functions that are less clear than inline code
- Adding a CLI parser when the user did not ask for command-line options and the existing file was not already a CLI
- Reimplementing existing project helpers inline, such as writing `(x + y - 1) // y` when the codebase already has `ceil_div(x, y)`

## Bundled Resources

- `references/ruff.md` - Linting and formatting guidance
- `references/pyright.md` - Static type checking guidance
- `references/pytest.md` - Testing guidance
