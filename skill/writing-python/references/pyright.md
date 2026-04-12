# Pyright - Python Static Type Checker

Pyright catches type issues before runtime. It is most useful when it matches the repository's current environment, Python version, and type-checking strictness.

## Runner Note

Commands below use bare `pyright`. If the repo uses a runner, prefix the command instead of changing the workflow:

```bash
pyright
uv run pyright
poetry run pyright
pipenv run pyright
```

## Safe Default Workflow

1. Check the current environment and config before changing code.
2. Run Pyright on the smallest relevant target first.
3. Fix imports, `None` handling, and obvious type mismatches before changing settings.
4. Use narrow suppressions only when the root cause cannot be fixed cleanly.
5. Avoid lowering strictness globally for a local problem.

Common commands:

```bash
pyright
pyright path/to/file.py
pyright path/to/package/
pyright --stats
```

Exit codes:

- `0` - no errors found
- `1` - errors found

## Configuration

Keep configuration in `pyproject.toml` or `pyrightconfig.json`:

```toml
[tool.pyright]
pythonVersion = "3.10"
typeCheckingMode = "basic"
include = ["src", "tests"]
exclude = ["**/__pycache__", "**/.venv", "**/node_modules"]
```

Type-checking modes:

- `basic` - good default for many repos
- `standard` - stronger checks with moderate annotation cost
- `strict` - strongest guarantees, highest maintenance cost

Match the repo's existing level instead of tightening or loosening it by default.

## How to Fix Common Diagnostics

### Missing Imports

Typical causes:

- the dependency is not installed in the active environment
- Pyright is running against the wrong interpreter or environment
- the file is outside `include`, or an exclude pattern is too broad

Fix order:

1. Confirm you are using the repo's expected runner or virtualenv.
2. Confirm the dependency belongs in the project before adding it.
3. Fix config or environment selection before muting the error.

Do not jump straight to `reportMissingImports = "none"`.

### Optional Member Access

Narrow `None` before accessing attributes.

```python
# Before
from pathlib import Path


def read_text(path: Path | None) -> str:
    return path.read_text(encoding="utf-8")


# After
from pathlib import Path


def read_text(path: Path | None) -> str:
    if path is None:
        raise ValueError("path is required")
    return path.read_text(encoding="utf-8")
```

### Argument Type Mismatch

Convert or validate data at the boundary instead of weakening the callee's type hints.

```python
# Before
def lookup_user(user_id: int) -> str:
    return f"user-{user_id}"


raw_user_id = "42"
name = lookup_user(raw_user_id)


# After
def lookup_user(user_id: int) -> str:
    return f"user-{user_id}"


raw_user_id = "42"
name = lookup_user(int(raw_user_id))
```

### Union Narrowing

Use `isinstance`, explicit guards, or early returns to narrow unions.

```python
def normalize(value: str | list[str]) -> list[str]:
    if isinstance(value, str):
        return [value]
    return value
```

### Overuse of `Any`

Prefer concrete types for function boundaries and data structures. If a value is truly dynamic, keep `Any` local and convert it into a typed structure as early as possible.

## Suppressions

Prefer fixing code or configuration before suppressing. When suppression is necessary, keep it narrow and explain why.

Good example:

```python
result = function("42")  # pyright: ignore[reportArgumentType]  # third-party stub is incorrect
```

Avoid:

- file-wide suppression for one line of code
- repo-wide settings such as `reportMissingImports = "none"` unless the repo already documents that tradeoff
- reducing `typeCheckingMode` to make a single edit pass

## Best Practices

1. Start with the repo's current strictness level.
2. Fix errors before warnings.
3. Add type hints where they improve clarity, especially at public boundaries.
4. Exclude generated or vendored code instead of muting diagnostics globally.
5. Keep suppressions narrow, commented, and rare.

## Resources

- Docs: https://microsoft.github.io/pyright/
- Configuration: https://microsoft.github.io/pyright/#/configuration
- Type Checking Modes: https://microsoft.github.io/pyright/#/type-checking-modes
